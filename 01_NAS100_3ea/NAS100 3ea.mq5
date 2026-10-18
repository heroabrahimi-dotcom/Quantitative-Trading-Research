#property strict
#property description "NAS100 simple NY / Asia / London REAL trading EA"
#property description "Implements the validated 1-2 condition spreadsheet signal rules using only data available before each session."
#property description "Keeps the existing risk sizing, optional same-direction STOP, retry protection, and regime monitor."

#include <Trade/Trade.mqh>
CTrade trade;

enum ENUM_S2_SIGNAL { S2_BUY=0, S2_SELL=1 };
enum ENUM_S2_SESSION { S2_ASIA=0, S2_LONDON=1, S2_NY=2 };
enum ENUM_S2_ZONE { S2_ABOVE=0, S2_BELOW=1, S2_EQUAL=2, S2_ZONE_INVALID=3 };

input group "=== Session 2 exact trading ==="
input long   MagicNumber = 26092701;
input bool   EnableAsia = true;
input bool   EnableLondon = true;
input bool   EnableNY = true;
input double SheetRiskAmount = 600.0;       // risk amount used for lot sizing
input bool   UseStopLoss = true;               // false = current no-SL behavior
input double SL_Multiplier = 1.0;               // 1.0 = original avg*2 SL; 1.5 = 50% wider; 2.0 = twice as wide

input group "=== Same-direction stop order ==="
input bool   UseSameDirectionStopOrder = false;  // true = BUY signal -> BUY STOP; SELL signal -> SELL STOP
input bool   StopOrdersOnly = false;              // true = only place the pending STOP; no market entry
input double StopOrderDistanceMultiplier = 1.0; // 1.0 = same distance as calculated SL distance
input double StopOrderLotMultiplier = 1.0;      // 1.0 = same lot size as main trade
input bool   UseStopOrderSL = false;                // true = attach SL to the pending stop order
input double StopOrderSLMultiplier = 1.0;           // 1.0 = SL distance equals calculated strategy distance

input group "=== Session sizing / execution ==="
input int    LookbackSessions = 144;         // spreadsheet H/S/AC lookback
input double SheetPipsPerPriceUnit = 10.0;   // sheet uses (price difference)*10
input int    MaxEntryDelaySeconds = 120;
input int    MaxDeviationPoints = 30;
input bool   RequireHedgingAccount = true;

input group "=== EMA50 NY rule — calculated on ALL years ==="
input int EMA_Period = 50;

input group "=== Broker clock / DST (matches supplied sheet windows) ==="
input int  Broker_UTC_Offset_Winter = 2;
input int  Broker_UTC_Offset_Summer = 3;
input bool Broker_Follows_EU_DST = true;

input group "=== Global reverse ==="
input bool ReverseAllSignals = false; // true = flip every BUY<->SELL before sending

input group "=== EA regime monitor panel ==="
input bool ShowRegimePanel = false;          // informational only; does NOT change trades
input int  PanelX = 10;                     // pixels from left
input int  PanelY = 25;                     // pixels from top
input int  PanelWidth = 330;
input int  PanelHeight = 390;
input int  RegimeShortTrades = 20;          // short rolling EA win rate
input int  RegimeLongTrades = 60;           // long rolling EA win rate
input int  RegimeATRPeriod = 14;
input int  RegimeATRBaselineBars = 20;
input int  RegimeEMA200Period = 200;
input int  RegimeEMABaselineBars = 20;
input bool UseHistoricalRegimeBackfill = true; // calculate last 20/60 strategy signals from market history when account history is insufficient
input bool TrackRegimeBacktestStats = true; // track realized P/L separately for GREEN / YELLOW / RED


// Core rule constants
const int    SHEET_LOOKBACK = 144;
const double SHEET_RISK = 600.0;

// Strategy signal rules are fixed in ComputeBaseSignal().
// No A/B cycle or post-signal reversal is applied.

int g_emaHandle = INVALID_HANDLE;
int g_regimeATRHandle = INVALID_HANDLE;
int g_regimeEMA200Handle = INVALID_HANDLE;
int g_audit = INVALID_HANDLE;


string REGIME_PANEL_PREFIX = "S2REG_";

// Backtest/live regime performance tracking.
// Each filled position is stamped with the regime that existed at its ACTUAL fill time.
ulong  g_regPosId[];
int    g_regPosCode[];      // 0=GREEN, 1=YELLOW, 2=RED
double g_regPosPnl[];

int    g_regTrades[3] = {0,0,0};
int    g_regWins[3]   = {0,0,0};
int    g_regLosses[3] = {0,0,0};
double g_regNet[3]    = {0.0,0.0,0.0};
double g_regGrossWin[3]  = {0.0,0.0,0.0};
double g_regGrossLoss[3] = {0.0,0.0,0.0};


int g_lastOpenKey[3]  = {0,0,0};
int g_lastCloseKey[3] = {0,0,0};

// Historical regime range currently used by the [HIST] panel.
datetime g_histRangeStart = 0; // oldest included historical strategy session
datetime g_histRangeEnd   = 0; // newest included historical strategy session

//----------------------------------------------------------------------
// Time / date helpers
//----------------------------------------------------------------------
datetime StartOfDay(datetime t)
{
   MqlDateTime x; TimeToStruct(t,x);
   x.hour=0; x.min=0; x.sec=0;
   return StructToTime(x);
}

int DateKey(datetime t)
{
   MqlDateTime x; TimeToStruct(t,x);
   return x.year*10000 + x.mon*100 + x.day;
}

datetime DateFromKey(int key)
{
   MqlDateTime x;
   x.year=key/10000;
   x.mon=(key/100)%100;
   x.day=key%100;
   x.hour=0; x.min=0; x.sec=0;
   return StructToTime(x);
}

datetime NthWeekdayOfMonth(int year,int month,int weekday,int n)
{
   MqlDateTime t;
   t.year=year; t.mon=month; t.day=1; t.hour=0; t.min=0; t.sec=0;
   if(n>0)
   {
      datetime first=StructToTime(t);
      MqlDateTime f; TimeToStruct(first,f);
      int add=(weekday-f.day_of_week+7)%7;
      t.day=1+add+(n-1)*7;
      return StructToTime(t);
   }
   int nm=month+1, ny=year;
   if(nm>12){nm=1;ny++;}
   MqlDateTime nt; nt.year=ny;nt.mon=nm;nt.day=1;nt.hour=0;nt.min=0;nt.sec=0;
   datetime last=StructToTime(nt)-86400;
   MqlDateTime l; TimeToStruct(last,l);
   int back=(l.day_of_week-weekday+7)%7;
   return last-back*86400;
}

bool IsEUDST_BrokerLocal(datetime brokerTime)
{
   MqlDateTime t; TimeToStruct(brokerTime,t);
   datetime start=NthWeekdayOfMonth(t.year,3,0,-1)+3*3600;
   datetime end  =NthWeekdayOfMonth(t.year,10,0,-1)+4*3600;
   return brokerTime>=start && brokerTime<end;
}

bool IsUSDST_UTC(datetime utcTime)
{
   MqlDateTime t; TimeToStruct(utcTime,t);
   datetime start=NthWeekdayOfMonth(t.year,3,0,2)+7*3600;
   datetime end  =NthWeekdayOfMonth(t.year,11,0,1)+6*3600;
   return utcTime>=start && utcTime<end;
}

void BrokerOffsetForDay(datetime day,int &offset,bool &euDST)
{
   euDST = Broker_Follows_EU_DST ? IsEUDST_BrokerLocal(day+12*3600) : false;
   offset = euDST ? Broker_UTC_Offset_Summer : Broker_UTC_Offset_Winter;
}

void ComputeSessionWindow(ENUM_S2_SESSION sess,datetime day,datetime &start,datetime &end)
{
   int bo; bool eu; BrokerOffsetForDay(day,bo,eu);
   int oh=0,om=0,ch=0,cm=0;

   if(sess==S2_ASIA)
   {
      // Spreadsheet windows: 02:00-08:00 in broker winter, 03:00-09:00 in summer.
      oh=bo; om=0; ch=bo+6; cm=0;
   }
   else if(sess==S2_LONDON)
   {
      // Spreadsheet window is constant broker time.
      oh=10; om=30; ch=18; cm=30;
   }
   else
   {
      // Spreadsheet NY: 09:30-16:00 New York translated to broker server time.
      datetime approxUTC=day+(12-bo)*3600;
      int nyOffset=IsUSDST_UTC(approxUTC) ? -4 : -5;
      int openMin = 9*60+30 - nyOffset*60 + bo*60;
      int closeMin=16*60    - nyOffset*60 + bo*60;
      openMin=((openMin%1440)+1440)%1440;
      closeMin=((closeMin%1440)+1440)%1440;
      oh=openMin/60; om=openMin%60;
      ch=closeMin/60; cm=closeMin%60;
   }

   start=day+oh*3600+om*60;
   end  =day+ch*3600+cm*60;
}

string SessionName(ENUM_S2_SESSION s)
{
   if(s==S2_ASIA) return "ASIA";
   if(s==S2_LONDON) return "LONDON";
   return "NY";
}

string SessionTag(ENUM_S2_SESSION s)
{
   if(s==S2_ASIA) return "S2A";
   if(s==S2_LONDON) return "S2L";
   return "S2N";
}

string SignalName(ENUM_S2_SIGNAL s){ return s==S2_BUY ? "BUY" : "SELL"; }
string ZoneName(ENUM_S2_ZONE z)
{
   if(z==S2_ABOVE) return "ABOVE";
   if(z==S2_BELOW) return "BELOW";
   if(z==S2_EQUAL) return "EQUAL";
   return "INVALID";
}

//----------------------------------------------------------------------
// Raw session reconstruction - same formulas as spreadsheet inputs
//----------------------------------------------------------------------
bool GetSessionDirection(datetime sessStart,datetime sessEnd,string &dir)
{
   MqlRates r[]; ArraySetAsSeries(r,false);
   int n=CopyRates(_Symbol,PERIOD_M30,sessStart,sessEnd,r);
   if(n<=0) return false;
   double op=r[0].open;
   double exitOpen=r[n-1].open; // endpoint bar OPEN, exactly like the sheet reconstruction
   dir=(exitOpen>op) ? "BUY" : "SELL";
   return true;
}

bool GetSessionRange(datetime sessStart,datetime sessEnd,double &buyPips,double &sellPips)
{
   MqlRates r[]; ArraySetAsSeries(r,false);
   int n=CopyRates(_Symbol,PERIOD_M30,sessStart,sessEnd,r);
   if(n<=0) return false;
   double op=r[0].open, hi=r[0].high, lo=r[0].low;
   for(int i=1;i<n;i++)
   {
      if(r[i].high>hi) hi=r[i].high;
      if(r[i].low <lo) lo=r[i].low;
   }
   buyPips =(hi-op)*SheetPipsPerPriceUnit;
   sellPips=(op-lo)*SheetPipsPerPriceUnit;
   return true;
}

bool FindLastClosedSession(ENUM_S2_SESSION sess,datetime beforeTime,
                           datetime &foundStart,datetime &foundEnd,string &dir)
{
   datetime base=StartOfDay(beforeTime);
   for(int back=0;back<20;back++)
   {
      datetime d=base-back*86400;
      datetime s,e; ComputeSessionWindow(sess,d,s,e);
      if(e>=beforeTime) continue;
      string x;
      if(GetSessionDirection(s,e,x))
      {
         foundStart=s; foundEnd=e; dir=x;
         return true;
      }
   }
   return false;
}

//----------------------------------------------------------------------
// EMA50 NY classification — RULES ONLY, ALL YEARS
// If EMA50 lies inside any H1 candle body during completed NY -> EQUAL,
// otherwise classify the final completed NY close as ABOVE or BELOW EMA50.
//----------------------------------------------------------------------
bool EMAValueAt(datetime barTime,double &ema)
{
   if(g_emaHandle==INVALID_HANDLE) return false;
   int shift=iBarShift(_Symbol,PERIOD_H1,barTime,true);
   if(shift<0) return false;
   double b[1];
   if(CopyBuffer(g_emaHandle,0,shift,1,b)!=1) return false;
   ema=b[0];
   return true;
}

bool ComputeEMAZone(datetime nyStart,datetime nyEnd,ENUM_S2_ZONE &zone)
{
   MqlRates r[]; ArraySetAsSeries(r,false);
   int n=CopyRates(_Symbol,PERIOD_H1,nyStart-3600,nyEnd,r);
   if(n<=0) return false;

   bool got=false;
   double lastClose=0,lastEMA=0;
   for(int i=0;i<n;i++)
   {
      if(r[i].time<nyStart || r[i].time>=nyEnd) continue;
      double ema;
      if(!EMAValueAt(r[i].time,ema)) continue;
      got=true; lastClose=r[i].close; lastEMA=ema;
      double lo=MathMin(r[i].open,r[i].close);
      double hi=MathMax(r[i].open,r[i].close);
      if(ema>=lo && ema<=hi)
      {
         zone=S2_EQUAL;
         return true;
      }
   }
   if(!got) return false;
   zone=(lastClose>lastEMA) ? S2_ABOVE : S2_BELOW;
   return true;
}

bool GetNYZoneForRowDate(datetime rowDay,datetime nyStart,datetime nyEnd,ENUM_S2_ZONE &zone)
{
   // rowDay is kept in the function signature because the calling strategy
   // logic uses spreadsheet-style row dates, but the zone itself is ALWAYS
   // calculated from market data. No historical label lookup.
   return ComputeEMAZone(nyStart,nyEnd,zone);
}

//----------------------------------------------------------------------
// Market-day helper
//----------------------------------------------------------------------
bool HasMarketDataOnDay(datetime day)
{
   MqlDateTime t; TimeToStruct(day,t);
   if(t.day_of_week==0 || t.day_of_week==6) return false;

   MqlRates r[];
   ArraySetAsSeries(r,false);
   return CopyRates(_Symbol,PERIOD_M30,day,day+86399,r)>0;
}

//----------------------------------------------------------------------
// Exact 144-session H/S/AC lookback — MARKET DATA ONLY
//----------------------------------------------------------------------

bool ComputePreviousAverage(ENUM_S2_SESSION sess,datetime currentSessionStart,
                            double &avgPips,int &count,string &info)
{
   int want=LookbackSessions;
   if(want<=0) want=SHEET_LOOKBACK;

   double sum=0.0;
   count=0;
   datetime base=StartOfDay(currentSessionStart);

   // Scan only real closed sessions available in MT5 history.
   // No workbook seeds and no historical copied values.
   for(int back=0;back<1200 && count<want;back++)
   {
      datetime d=base-back*86400;
      datetime s,e;
      ComputeSessionWindow(sess,d,s,e);

      if(e>=currentSessionStart)
         continue;

      double bp,sp;
      if(!GetSessionRange(s,e,bp,sp))
         continue;

      sum += bp+sp;
      count++;
   }

   if(count<want)
   {
      info=StringFormat("only %d/%d real prior sessions available",count,want);
      return false;
   }

   avgPips=sum/(count*2.0);
   info=StringFormat("avg=%.6f from %d real prior sessions",avgPips,count);
   return true;
}

//----------------------------------------------------------------------
// Signals - exact simple spreadsheet rules, using ONLY data available at entry
//----------------------------------------------------------------------
ENUM_S2_SIGNAL ReverseSignal(ENUM_S2_SIGNAL s){ return s==S2_BUY ? S2_SELL : S2_BUY; }

bool PreviousMarketDay(datetime rowDay,int n,datetime &outDay)
{
   if(n<=0) { outDay=StartOfDay(rowDay); return true; }
   int found=0;
   datetime d=StartOfDay(rowDay)-86400;
   for(int back=0; back<40; back++,d-=86400)
   {
      if(!HasMarketDataOnDay(d)) continue;
      found++;
      if(found==n)
      {
         outDay=d;
         return true;
      }
   }
   return false;
}

bool SessionDirectionForDay(ENUM_S2_SESSION sess,datetime day,string &dir)
{
   datetime s,e;
   ComputeSessionWindow(sess,StartOfDay(day),s,e);
   return GetSessionDirection(s,e,dir);
}

bool NYZoneForDay(datetime day,ENUM_S2_ZONE &zone)
{
   datetime s,e;
   ComputeSessionWindow(S2_NY,StartOfDay(day),s,e);
   return ComputeEMAZone(s,e,zone);
}

ENUM_S2_SIGNAL SignalFromString(const string d)
{
   return (d=="BUY") ? S2_BUY : S2_SELL;
}

string Majority3(const string a,const string b,const string c)
{
   int buys=(a=="BUY")+(b=="BUY")+(c=="BUY");
   return (buys>=2) ? "BUY" : "SELL";
}

// IMPORTANT SPREADSHEET DATE MAPPING:
// A spreadsheet row dated D contains:
//   B/Y = the PREVIOUS trading day's NY direction / NY EMA-zone,
//   J   = Asia on D,
//   Q   = London on D.
// Therefore today's NY result is written on TOMORROW's spreadsheet row.
//
// For an actual NY session on day D, the tested spreadsheet formula becomes:
// IF(NY(D-3)=BUY,
//      IF(EMAzone(D-3)=ABOVE, reverse(NY(D-2)), reverse(London(D-2))),
//      reverse(NY(D-1)))
// Note the London reference is D-2, because London is NOT shifted like NY in the sheet.
bool ComputeNYRule(datetime rowDay,ENUM_S2_SIGNAL &signal,string &info)
{
   datetime d1,d2,d3;
   if(!PreviousMarketDay(rowDay,1,d1) ||
      !PreviousMarketDay(rowDay,2,d2) ||
      !PreviousMarketDay(rowDay,3,d3))
   { info="NY: insufficient prior market days"; return false; }

   string ny1,ny2,ny3,lon2;
   ENUM_S2_ZONE z3;
   if(!SessionDirectionForDay(S2_NY,d1,ny1) ||
      !SessionDirectionForDay(S2_NY,d2,ny2) ||
      !SessionDirectionForDay(S2_NY,d3,ny3) ||
      !SessionDirectionForDay(S2_LONDON,d2,lon2) ||
      !NYZoneForDay(d3,z3))
   { info="NY: required history unavailable"; return false; }

   if(ny3=="BUY")
   {
      if(z3==S2_ABOVE)
         signal=ReverseSignal(SignalFromString(ny2));
      else
         signal=ReverseSignal(SignalFromString(lon2));
   }
   else
      signal=ReverseSignal(SignalFromString(ny1));

   info=StringFormat("NY rule | NY3=%s EMA3=%s NY2=%s L2=%s NY1=%s -> %s",
                     ny3,ZoneName(z3),ny2,lon2,ny1,SignalName(signal));
   return true;
}

// Asia formula:
// IF(prev Asia = prev London, use prev NY,
//    else majority(prev London, London 2-back, London 3-back))
bool ComputeAsiaRule(datetime rowDay,ENUM_S2_SIGNAL &signal,string &info)
{
   datetime d1,d2,d3;
   if(!PreviousMarketDay(rowDay,1,d1) ||
      !PreviousMarketDay(rowDay,2,d2) ||
      !PreviousMarketDay(rowDay,3,d3))
   { info="Asia: insufficient prior market days"; return false; }

   // Spreadsheet B on the previous row is NOT yesterday's calendar NY.
   // Because NY is written one row later, B(prev row) = actual NY two trading days ago.
   string a1,l1,l2,l3,n2;
   if(!SessionDirectionForDay(S2_ASIA,d1,a1) ||
      !SessionDirectionForDay(S2_LONDON,d1,l1) ||
      !SessionDirectionForDay(S2_LONDON,d2,l2) ||
      !SessionDirectionForDay(S2_LONDON,d3,l3) ||
      !SessionDirectionForDay(S2_NY,d2,n2))
   { info="Asia: required history unavailable"; return false; }

   string out=(a1==l1) ? n2 : Majority3(l1,l2,l3);
   signal=SignalFromString(out);
   info=StringFormat("Asia rule | A1=%s L1=%s Bprev(NY2)=%s L2=%s L3=%s -> %s",
                     a1,l1,n2,l2,l3,out);
   return true;
}

// London formula:
// IF(today Asia = prev London, reverse(London 2-back),
//    IF(today Asia = prev NY, use London 2-back, use previous NY SIGNAL))
// The previous NY signal is reconstructed by the exact NY rule above.
bool ComputeLondonRule(datetime entryTime,datetime rowDay,ENUM_S2_SIGNAL &signal,string &info)
{
   datetime aS,aE;
   ComputeSessionWindow(S2_ASIA,StartOfDay(rowDay),aS,aE);
   if(aE>=entryTime)
   { info="London: current Asia has not closed yet"; return false; }

   string a0;
   if(!GetSessionDirection(aS,aE,a0))
   { info="London: current Asia direction unavailable"; return false; }

   datetime d1,d2;
   if(!PreviousMarketDay(rowDay,1,d1) || !PreviousMarketDay(rowDay,2,d2))
   { info="London: insufficient prior market days"; return false; }

   // Spreadsheet B/C on the previous row refer to actual NY two trading days ago.
   string l1,l2,n2;
   if(!SessionDirectionForDay(S2_LONDON,d1,l1) ||
      !SessionDirectionForDay(S2_LONDON,d2,l2) ||
      !SessionDirectionForDay(S2_NY,d2,n2))
   { info="London: required history unavailable"; return false; }

   if(a0==l1)
      signal=ReverseSignal(SignalFromString(l2));
   else if(a0==n2)
      signal=SignalFromString(l2);
   else
   {
      ENUM_S2_SIGNAL prevNYSignal; string prevInfo;
      // C(previous sheet row) predicts B(previous sheet row), which is actual NY on D-2.
      if(!ComputeNYRule(d2,prevNYSignal,prevInfo))
      { info="London: previous-row NY signal unavailable"; return false; }
      signal=prevNYSignal;
   }

   info=StringFormat("London rule | A0=%s L1=%s L2=%s Bprev(NY2)=%s -> %s",
                     a0,l1,l2,n2,SignalName(signal));
   return true;
}

bool ComputeBaseSignal(ENUM_S2_SESSION sess,datetime entryTime,datetime rowDay,
                       ENUM_S2_SIGNAL &signal,string &info)
{
   if(sess==S2_ASIA)
      return ComputeAsiaRule(rowDay,signal,info);
   if(sess==S2_LONDON)
      return ComputeLondonRule(entryTime,rowDay,signal,info);
   return ComputeNYRule(rowDay,signal,info);
}

//----------------------------------------------------------------------
// Exact spreadsheet scaling translated to a REAL MT5 position
// Sheet: slLimit = avg*2, scale = 600/slLimit.
// In real trading, lot size is chosen so that the actual broker SL costs ~600
// account-currency units. OrderCalcProfit handles broker contract size/tick value.
//----------------------------------------------------------------------
double NormalizePriceToTick(double price)
{
   double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   if(tick>0) price=MathRound(price/tick)*tick;
   return NormalizeDouble(price,digits);
}

int VolumeDigits(double step)
{
   int d=0;
   while(d<8 && MathAbs(step-NormalizeDouble(step,d))>1e-12) d++;
   return d;
}

double NormalizeVolumeNearest(double lots)
{
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double mn=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double mx=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   if(step<=0) step=0.01;
   lots=MathRound(lots/step)*step;
   lots=MathMax(mn,MathMin(mx,lots));
   return NormalizeDouble(lots,VolumeDigits(step));
}

bool LotsForRisk(ENUM_S2_SIGNAL sig,double entry,double sl,double risk,double &lots,double &oneLotLoss)
{
   ENUM_ORDER_TYPE type=(sig==S2_BUY)?ORDER_TYPE_BUY:ORDER_TYPE_SELL;
   double pnl=0;
   if(!OrderCalcProfit(type,_Symbol,1.0,entry,sl,pnl)) return false;
   oneLotLoss=MathAbs(pnl);
   if(oneLotLoss<=0) return false;
   lots=NormalizeVolumeNearest(risk/oneLotLoss);
   return lots>0;
}


bool HasExistingSameDirectionStopExposure(ENUM_S2_SIGNAL stopSig,string pcomment)
{
   // Prevent duplicates before the first send and before every retry.
   // Check both pending orders and positions in case a STOP was accepted
   // and triggered before the EA got around to retrying it.
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      ulong ticket=OrderGetTicket(i);
      if(ticket==0) continue;
      if(OrderGetString(ORDER_SYMBOL)!=_Symbol) continue;
      if(OrderGetInteger(ORDER_MAGIC)!=MagicNumber) continue;

      string c=OrderGetString(ORDER_COMMENT);
      if(c!=pcomment) continue;

      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      if(stopSig==S2_BUY && type==ORDER_TYPE_BUY_STOP)  return true;
      if(stopSig==S2_SELL && type==ORDER_TYPE_SELL_STOP) return true;
   }

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=MagicNumber) continue;

      string c=PositionGetString(POSITION_COMMENT);
      if(c!=pcomment) continue;

      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(stopSig==S2_BUY && type==POSITION_TYPE_BUY)  return true;
      if(stopSig==S2_SELL && type==POSITION_TYPE_SELL) return true;
   }

   return false;
}

bool PlaceSameDirectionStopOrder(ENUM_S2_SESSION sess,
                                 ENUM_S2_SIGNAL mainSig,
                                 double referencePrice,
                                 double mainLots,
                                 double baseDistance,
                                 string tag)
{
   if(!UseSameDirectionStopOrder && !StopOrdersOnly)
      return true;

   double dm=(StopOrderDistanceMultiplier>0.0)?StopOrderDistanceMultiplier:1.0;
   double stopDistance=baseDistance*dm;

   double stopLots=NormalizeVolumeNearest(mainLots*((StopOrderLotMultiplier>0.0)?StopOrderLotMultiplier:1.0));
   if(stopLots<=0.0)
   {
      Print("S2 ",SessionName(sess),": same-direction stop-order lot size invalid.");
      return false;
   }

   ENUM_S2_SIGNAL stopSig=mainSig;
   string pcomment=tag+"-PSTOP-"+SignalName(stopSig);

   // If the STOP already exists (or has already triggered into a position),
   // treat the job as complete and NEVER submit a duplicate.
   if(HasExistingSameDirectionStopExposure(stopSig,pcomment))
   {
      Print("S2 ",SessionName(sess),": matching stop exposure already exists; duplicate send skipped.");
      return true;
   }

   const int MAX_RETRIES=2;              // two retries AFTER the first failed send
   const int MAX_ATTEMPTS=1+MAX_RETRIES; // maximum three total submission attempts

   for(int attempt=1; attempt<=MAX_ATTEMPTS; attempt++)
   {
      // Before every retry, check again. The previous request could have been
      // accepted/triggered even if the local call did not look successful.
      if(HasExistingSameDirectionStopExposure(stopSig,pcomment))
      {
         PrintFormat("S2 %s PENDING %s STOP already exists before attempt %d; retry cancelled.",
                     SessionName(sess),SignalName(stopSig),attempt);
         return true;
      }

      double minDist=(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
      double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
      if(tick<=0.0) tick=_Point;

      double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);

      // Recalculate from the latest market price on every attempt.
      // This prevents a fast NAS100 move from making the original STOP price invalid.
      double wantedPrice=(stopSig==S2_BUY)
                         ? referencePrice+stopDistance
                         : referencePrice-stopDistance;

      double stopPrice;
      if(stopSig==S2_BUY)
         stopPrice=NormalizePriceToTick(MathMax(wantedPrice,ask+minDist+tick));
      else
         stopPrice=NormalizePriceToTick(MathMin(wantedPrice,bid-minDist-tick));

      // Optional SL attached to the pending STOP order.
      double pendingSL=0.0;
      if(UseStopOrderSL)
      {
         double slm=(StopOrderSLMultiplier>0.0)?StopOrderSLMultiplier:1.0;
         double slDistance=baseDistance*slm;
         pendingSL=NormalizePriceToTick(stopSig==S2_BUY
                                        ? stopPrice-slDistance
                                        : stopPrice+slDistance);

         double brokerMinDist=(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
         if(MathAbs(stopPrice-pendingSL)+1e-12<brokerMinDist)
         {
            Print("S2 ",SessionName(sess),
                  ": pending-order SL is inside broker minimum stop distance; order skipped.");
            return false;
         }
      }

      bool ok=(stopSig==S2_BUY)
              ? trade.BuyStop(stopLots,stopPrice,_Symbol,pendingSL,0.0,ORDER_TIME_GTC,0,pcomment)
              : trade.SellStop(stopLots,stopPrice,_Symbol,pendingSL,0.0,ORDER_TIME_GTC,0,pcomment);

      if(ok)
      {
         PrintFormat("S2 %s PENDING %s STOP PLACED | attempt=%d price=%.5f distance=%.5f lots=%.2f SL=%.5f",
                     SessionName(sess),SignalName(stopSig),attempt,stopPrice,stopDistance,stopLots,pendingSL);
         return true; // success => absolutely no more retries
      }

      PrintFormat("S2 %s pending stop order FAILED | attempt=%d/%d %s price=%.5f lots=%.2f ret=%u (%s)",
                  SessionName(sess),attempt,MAX_ATTEMPTS,SignalName(stopSig),stopPrice,stopLots,
                  trade.ResultRetcode(),trade.ResultRetcodeDescription());

      // Check once more immediately after a failed return before deciding to retry.
      if(HasExistingSameDirectionStopExposure(stopSig,pcomment))
      {
         Print("S2 ",SessionName(sess),": stop exposure found after failed return; no duplicate retry sent.");
         return true;
      }

      if(attempt<MAX_ATTEMPTS)
         Sleep(250);
   }

   PrintFormat("S2 %s pending %s STOP failed after %d attempts; no duplicate order exists.",
               SessionName(sess),SignalName(stopSig),MAX_ATTEMPTS);
   return false;
}

bool OpenSessionTrade(ENUM_S2_SESSION sess,datetime sessionStart,datetime rowDay)
{
   ENUM_S2_SIGNAL base;
   string sigInfo;
   if(!ComputeBaseSignal(sess,sessionStart,rowDay,base,sigInfo))
   {
      Print("S2 ",SessionName(sess),": signal unavailable: ",sigInfo);
      return false;
   }

   ENUM_S2_SIGNAL finalSig=base;
   if(ReverseAllSignals)
      finalSig=ReverseSignal(finalSig);

   double avg; int count; string avgInfo;
   if(!ComputePreviousAverage(sess,sessionStart,avg,count,avgInfo))
   {
      Print("S2 ",SessionName(sess),": sizing unavailable: ",avgInfo);
      return false;
   }

   double slLimitPips=avg*2.0;
   double baseDistance=slLimitPips/SheetPipsPerPriceUnit;
   double mult=(SL_Multiplier>0.0)?SL_Multiplier:1.0;
   double distance=baseDistance*mult;
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double entry=(finalSig==S2_BUY)?ask:bid;
   double sl=NormalizePriceToTick(finalSig==S2_BUY ? entry-distance : entry+distance);

   if(UseStopLoss)
   {
      double minDist=(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
      if(MathAbs(entry-sl)+1e-12<minDist)
      {
         Print("S2 ",SessionName(sess),": selected SL is inside broker minimum stop distance; trade skipped.");
         return false;
      }
   }

   double risk=(SheetRiskAmount>0)?SheetRiskAmount:SHEET_RISK;
   double lots,oneLotLoss;
   // Lot size uses the selected SL distance, so an SL hit remains approximately SheetRiskAmount.
   if(!LotsForRisk(finalSig,entry,sl,risk,lots,oneLotLoss))
   {
      Print("S2 ",SessionName(sess),": lot calculation failed.");
      return false;
   }
   string tag=SessionTag(sess);

   // STOP-ORDERS-ONLY MODE:
   // No market position is opened at session start.
   // BUY signal  -> BUY STOP above current Ask.
   // SELL signal -> SELL STOP below current Bid.
   if(StopOrdersOnly)
   {
      double referencePrice=entry;
      bool pendingOk=PlaceSameDirectionStopOrder(sess,finalSig,referencePrice,lots,distance,tag);

      PrintFormat("S2 %s STOP-ONLY %s | rule=%s | avg=%.6f SLlim=%.6f dist=%.5f lots=%.2f reference=%.5f",
                  SessionName(sess),SignalName(finalSig),sigInfo,
                  avg,slLimitPips,distance,lots,referencePrice);

      if(g_audit!=INVALID_HANDLE)
      {
         FileWrite(g_audit,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),SessionName(sess),
                   DateKey(rowDay),SignalName(base),SignalName(finalSig),sigInfo,
                   avg,slLimitPips,distance,lots,referencePrice,0.0,
                   pendingOk?"STOP_ONLY_PLACED":"STOP_ONLY_FAILED",trade.ResultRetcode());
         FileFlush(g_audit);
      }
      return pendingOk;
   }

   // Normal market-entry mode.
   double orderSL=UseStopLoss ? sl : 0.0;
   string comment=tag+"-SIMPLE-"+SignalName(finalSig);
   bool ok=(finalSig==S2_BUY)
            ? trade.Buy(lots,_Symbol,0.0,orderSL,0.0,comment)
            : trade.Sell(lots,_Symbol,0.0,orderSL,0.0,comment);

   double fill=trade.ResultPrice();

   // Optional additional same-direction pending STOP order.
   if(ok && UseSameDirectionStopOrder)
      PlaceSameDirectionStopOrder(sess,finalSig,fill,lots,distance,tag);

   PrintFormat("S2 %s OPEN %s | rule=%s | avg=%.6f SLlim=%.6f dist=%.5f lots=%.2f fill=%.5f SL=%.5f",
               SessionName(sess),SignalName(finalSig),sigInfo,
               avg,slLimitPips,distance,lots,fill,orderSL);

   if(g_audit!=INVALID_HANDLE)
   {
      FileWrite(g_audit,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),SessionName(sess),
                DateKey(rowDay),SignalName(base),SignalName(finalSig),sigInfo,
                avg,slLimitPips,distance,lots,fill,orderSL,ok?"OPENED":"FAILED",trade.ResultRetcode());
      FileFlush(g_audit);
   }
   return ok;
}


//----------------------------------------------------------------------
// Safety close: close any Session2 position whose intended session end
// has already passed. This is derived from the position open date, so it
// still works if there was no tick at the exact close time or MT5 was
// restarted before the next tick.
//----------------------------------------------------------------------
bool SessionFromComment(const string c,ENUM_S2_SESSION &sess)
{
   if(StringFind(c,SessionTag(S2_ASIA))==0)   { sess=S2_ASIA;   return true; }
   if(StringFind(c,SessionTag(S2_LONDON))==0) { sess=S2_LONDON; return true; }
   if(StringFind(c,SessionTag(S2_NY))==0)      { sess=S2_NY;     return true; }
   return false;
}

void CloseOverdueSessionPositions(datetime now)
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=MagicNumber) continue;

      ENUM_S2_SESSION sess;
      string c=PositionGetString(POSITION_COMMENT);
      if(!SessionFromComment(c,sess)) continue;

      datetime opened=(datetime)PositionGetInteger(POSITION_TIME);
      datetime openDay=StartOfDay(opened);
      datetime s,e;
      ComputeSessionWindow(sess,openDay,s,e);

      // Defensive handling in case a future session definition crosses midnight.
      if(e<=s) e+=86400;

      if(now>=e)
      {
         if(trade.PositionClose(ticket))
         {
            PrintFormat("S2 %s OVERDUE CLOSE | ticket=%I64u opened=%s scheduledClose=%s actualCloseTick=%s",
                        SessionName(sess),ticket,
                        TimeToString(opened,TIME_DATE|TIME_SECONDS),
                        TimeToString(e,TIME_DATE|TIME_SECONDS),
                        TimeToString(now,TIME_DATE|TIME_SECONDS));
         }
         else
         {
            PrintFormat("S2 %s OVERDUE CLOSE FAILED | ticket=%I64u ret=%u",
                        SessionName(sess),ticket,trade.ResultRetcode());
         }
      }
   }
}


void DeleteSessionPendingOrders(ENUM_S2_SESSION sess)
{
   string tag=SessionTag(sess);

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      ulong ticket=OrderGetTicket(i);
      if(ticket==0) continue;
      if(OrderGetString(ORDER_SYMBOL)!=_Symbol) continue;
      if(OrderGetInteger(ORDER_MAGIC)!=MagicNumber) continue;

      string c=OrderGetString(ORDER_COMMENT);
      if(StringFind(c,tag)!=0) continue;

      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      bool pending=(type==ORDER_TYPE_BUY_LIMIT ||
                    type==ORDER_TYPE_SELL_LIMIT ||
                    type==ORDER_TYPE_BUY_STOP ||
                    type==ORDER_TYPE_SELL_STOP ||
                    type==ORDER_TYPE_BUY_STOP_LIMIT ||
                    type==ORDER_TYPE_SELL_STOP_LIMIT);
      if(!pending) continue;

      if(!trade.OrderDelete(ticket))
         Print("S2 pending-order delete failed ",tag," ticket=",ticket," ret=",trade.ResultRetcode());
   }
}

void CloseSessionPositions(ENUM_S2_SESSION sess)
{
   // Remove any unfilled same-direction STOP order for this session first.
   DeleteSessionPendingOrders(sess);

   string tag=SessionTag(sess);
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=MagicNumber) continue;
      string c=PositionGetString(POSITION_COMMENT);
      if(StringFind(c,tag)!=0) continue;
      if(!trade.PositionClose(ticket))
         Print("S2 close failed ",tag," ticket=",ticket," ret=",trade.ResultRetcode());
   }
}

bool HasOpenedTagToday(ENUM_S2_SESSION sess,datetime day)
{
   string tag=SessionTag(sess);
   if(!HistorySelect(day,TimeCurrent())) return false;
   int n=HistoryDealsTotal();
   for(int i=0;i<n;i++)
   {
      ulong d=HistoryDealGetTicket(i);
      if(d==0) continue;
      if(HistoryDealGetString(d,DEAL_SYMBOL)!=_Symbol) continue;
      if(HistoryDealGetInteger(d,DEAL_MAGIC)!=MagicNumber) continue;
      if(HistoryDealGetInteger(d,DEAL_ENTRY)!=DEAL_ENTRY_IN) continue;
      if(StringFind(HistoryDealGetString(d,DEAL_COMMENT),tag)==0) return true;
   }
   return false;
}

void ProcessSession(ENUM_S2_SESSION sess,bool enabled,datetime now)
{
   if(!enabled) return;
   datetime day=StartOfDay(now),s,e;
   ComputeSessionWindow(sess,day,s,e);
   int key=DateKey(day);

   // Close first, targeted only to this EA/session. London and NY overlap.
   if(now>=e && g_lastCloseKey[(int)sess]!=key)
   {
      CloseSessionPositions(sess);
      g_lastCloseKey[(int)sess]=key;
   }

   // Entry only at the actual session open; never open hours late after restart.
   if(now>=s && now<=s+MaxEntryDelaySeconds && g_lastOpenKey[(int)sess]!=key)
   {
      if(!HasOpenedTagToday(sess,day))
      {
         if(OpenSessionTrade(sess,s,day))
            g_lastOpenKey[(int)sess]=key;
      }
      else g_lastOpenKey[(int)sess]=key;
   }
}


//----------------------------------------------------------------------
// Informational EA regime monitor panel
// This panel NEVER blocks, flips, sizes, opens, closes, or modifies trades.
//----------------------------------------------------------------------


int RegimeCodeFromName(const string regime)
{
   if(regime=="GREEN") return 0;
   if(regime=="RED")   return 2;
   return 1; // YELLOW / fallback
}

string RegimeNameFromCode(int code)
{
   if(code==0) return "GREEN";
   if(code==2) return "RED";
   return "YELLOW";
}

int FindTrackedPosition(ulong positionId)
{
   int n=ArraySize(g_regPosId);
   for(int i=0;i<n;i++)
      if(g_regPosId[i]==positionId)
         return i;
   return -1;
}

int AddTrackedPosition(ulong positionId,int regimeCode)
{
   int n=ArraySize(g_regPosId);
   ArrayResize(g_regPosId,n+1);
   ArrayResize(g_regPosCode,n+1);
   ArrayResize(g_regPosPnl,n+1);
   g_regPosId[n]=positionId;
   g_regPosCode[n]=regimeCode;
   g_regPosPnl[n]=0.0;
   return n;
}

void RemoveTrackedPosition(int idx)
{
   int n=ArraySize(g_regPosId);
   if(idx<0 || idx>=n) return;

   for(int i=idx;i<n-1;i++)
   {
      g_regPosId[i]=g_regPosId[i+1];
      g_regPosCode[i]=g_regPosCode[i+1];
      g_regPosPnl[i]=g_regPosPnl[i+1];
   }

   ArrayResize(g_regPosId,n-1);
   ArrayResize(g_regPosCode,n-1);
   ArrayResize(g_regPosPnl,n-1);
}

string CurrentRegimeForTracking()
{
   int shortN=MathMax(RegimeShortTrades,1);
   int longN=MathMax(RegimeLongTrades,shortN);

   double wr20,wr60,pnl20,wrA,wrL,wrN;
   int got20,got60;
   bool liveOk=RecentEAStats(shortN,longN,wr20,wr60,pnl20,wrA,wrL,wrN,got20,got60);

   if((!liveOk || got20<shortN || got60<longN) && UseHistoricalRegimeBackfill)
   {
      double h20,h60,hA,hL,hN;
      int hg20,hg60;
      if(HistoricalStrategyStats(shortN,longN,h20,h60,hA,hL,hN,hg20,hg60))
      {
         wr20=h20;
         wr60=h60;
         got20=hg20;
         got60=hg60;
      }
   }

   double atrRatio,emaSepRatio,emaSlope;
   CurrentRegimeIndicators(atrRatio,emaSepRatio,emaSlope);

   if(got20<shortN || got60<longN)
      return "YELLOW";

   return RegimeName(wr20,wr60,atrRatio,emaSepRatio);
}

void FinalizeRegimePosition(int idx)
{
   if(idx<0 || idx>=ArraySize(g_regPosId)) return;

   int code=g_regPosCode[idx];
   double pnl=g_regPosPnl[idx];

   g_regTrades[code]++;
   g_regNet[code]+=pnl;

   if(pnl>0.0)
   {
      g_regWins[code]++;
      g_regGrossWin[code]+=pnl;
   }
   else
   {
      g_regLosses[code]++;
      g_regGrossLoss[code]+=MathAbs(pnl);
   }

   RemoveTrackedPosition(idx);
}

void PrintRegimeBacktestSummary()
{
   if(!TrackRegimeBacktestStats) return;

   string filename="Session2_Regime_Backtest_Stats.csv";
   int f=FileOpen(filename,FILE_WRITE|FILE_CSV|FILE_ANSI);
   if(f!=INVALID_HANDLE)
      FileWrite(f,"Regime","Trades","Wins","Losses","WinRatePct","NetProfit","GrossProfit","GrossLoss","ProfitFactor","AvgPerTrade");

   Print("==============================================================");
   Print("SESSION 2 REGIME PERFORMANCE SUMMARY");
   Print("Regime is fixed at each position's actual ENTRY/FILL time.");

   for(int code=0;code<3;code++)
   {
      int trades=g_regTrades[code];
      double wr=(trades>0)?100.0*g_regWins[code]/trades:0.0;
      double pf=(g_regGrossLoss[code]>0.0)?g_regGrossWin[code]/g_regGrossLoss[code]:0.0;
      double avg=(trades>0)?g_regNet[code]/trades:0.0;
      string name=RegimeNameFromCode(code);

      PrintFormat("%s | Trades=%d | WR=%.2f%% | Net=%.2f | PF=%.3f | Avg=%.2f",
                  name,trades,wr,g_regNet[code],pf,avg);

      if(f!=INVALID_HANDLE)
         FileWrite(f,name,trades,g_regWins[code],g_regLosses[code],wr,
                   g_regNet[code],g_regGrossWin[code],g_regGrossLoss[code],pf,avg);
   }

   Print("==============================================================");

   if(f!=INVALID_HANDLE)
      FileClose(f);
}

void DeleteRegimePanel()
{
   ObjectsDeleteAll(0,REGIME_PANEL_PREFIX);
}

void SetPanelLabel(const string name,const string value,int x,int y,int fontSize=9,color clr=clrWhite)
{
   string obj=REGIME_PANEL_PREFIX+name;
   if(ObjectFind(0,obj)<0)
      ObjectCreate(0,obj,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,obj,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,obj,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,obj,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,obj,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,obj,OBJPROP_COLOR,clr);
   ObjectSetString(0,obj,OBJPROP_FONT,"Arial");
   ObjectSetString(0,obj,OBJPROP_TEXT,value);
   ObjectSetInteger(0,obj,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,obj,OBJPROP_HIDDEN,true);
}

void EnsureRegimePanelBackground()
{
   string obj=REGIME_PANEL_PREFIX+"BG";
   if(ObjectFind(0,obj)<0)
      ObjectCreate(0,obj,OBJ_RECTANGLE_LABEL,0,0,0);

   ObjectSetInteger(0,obj,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,obj,OBJPROP_XDISTANCE,PanelX);
   ObjectSetInteger(0,obj,OBJPROP_YDISTANCE,PanelY);
   ObjectSetInteger(0,obj,OBJPROP_XSIZE,PanelWidth);
   ObjectSetInteger(0,obj,OBJPROP_YSIZE,PanelHeight);
   ObjectSetInteger(0,obj,OBJPROP_BGCOLOR,clrBlack);
   ObjectSetInteger(0,obj,OBJPROP_BORDER_COLOR,clrDimGray);
   ObjectSetInteger(0,obj,OBJPROP_BACK,false);
   ObjectSetInteger(0,obj,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,obj,OBJPROP_HIDDEN,true);
}

bool IsOurClosedDeal(ulong deal)
{
   if(deal==0) return false;
   if(HistoryDealGetString(deal,DEAL_SYMBOL)!=_Symbol) return false;
   if(HistoryDealGetInteger(deal,DEAL_MAGIC)!=MagicNumber) return false;

   long entry=HistoryDealGetInteger(deal,DEAL_ENTRY);
   return (entry==DEAL_ENTRY_OUT || entry==DEAL_ENTRY_OUT_BY);
}

string DealSessionFromComment(const string c)
{
   if(StringFind(c,SessionTag(S2_ASIA))==0) return "ASIA";
   if(StringFind(c,SessionTag(S2_LONDON))==0) return "LONDON";
   if(StringFind(c,SessionTag(S2_NY))==0) return "NY";
   return "";
}

// Reads the most recent closed deals generated by this EA.
// Return values are descriptive diagnostics only.

// Reconstructs the strategy's own historical session results directly from chart history.
// This lets the panel show 20/60 trade statistics immediately after attaching the EA,
// even if this account has not yet accumulated 60 live EA trades.
bool HistoricalStrategyStats(int shortN,int longN,
                             double &wrShort,double &wrLong,
                             double &wrAsia,double &wrLondon,double &wrNY,
                             int &gotShort,int &gotLong)
{
   wrShort=0; wrLong=0;
   wrAsia=0; wrLondon=0; wrNY=0;
   gotShort=0; gotLong=0;

   g_histRangeStart=0;
   g_histRangeEnd=0;

   int shortWins=0,longWins=0;
   int aN=0,aW=0,lN=0,lW=0,nN=0,nW=0;
   int sessionTarget=MathMax(shortN,20);

   datetime now=TimeCurrent();
   datetime today=StartOfDay(now);

   // Walk backwards through market days. 120 calendar days is normally
   // comfortably enough to reconstruct 60+ session trades.
   for(int back=0; back<180 && gotLong<longN; back++)
   {
      datetime day=today-back*86400;
      if(!HasMarketDataOnDay(day))
         continue;

      // Work backwards inside each day so the global sequence is newest -> oldest:
      // NY, London, Asia.
      for(int k=2;k>=0;k--)
      {
         ENUM_S2_SESSION sess=(ENUM_S2_SESSION)k;
         datetime s,e;
         ComputeSessionWindow(sess,day,s,e);

         if(e>=now)
            continue;

         // Require actual market data for the session.
         string actualDir;
         if(!GetSessionDirection(s,e,actualDir))
            continue;

         ENUM_S2_SIGNAL base;
         string info;
         if(!ComputeBaseSignal(sess,s,day,base,info))
            continue;

         ENUM_S2_SIGNAL finalSig=base;
         if(ReverseAllSignals)
            finalSig=ReverseSignal(finalSig);

         bool win=((finalSig==S2_BUY && actualDir=="BUY") ||
                   (finalSig==S2_SELL && actualDir=="SELL"));

         if(gotLong<longN)
         {
            // We walk newest -> oldest. The first included session is the
            // HIST range end; each later included session moves the range start back.
            if(g_histRangeEnd==0)
               g_histRangeEnd=day;
            g_histRangeStart=day;

            gotLong++;
            if(win) longWins++;
         }

         if(gotShort<shortN)
         {
            gotShort++;
            if(win) shortWins++;
         }

         if(sess==S2_ASIA && aN<sessionTarget)
         {
            aN++; if(win) aW++;
         }
         else if(sess==S2_LONDON && lN<sessionTarget)
         {
            lN++; if(win) lW++;
         }
         else if(sess==S2_NY && nN<sessionTarget)
         {
            nN++; if(win) nW++;
         }

         if(gotLong>=longN)
            break;
      }
   }

   if(gotShort>0) wrShort=100.0*shortWins/gotShort;
   if(gotLong>0)  wrLong =100.0*longWins/gotLong;
   if(aN>0) wrAsia=100.0*aW/aN;
   if(lN>0) wrLondon=100.0*lW/lN;
   if(nN>0) wrNY=100.0*nW/nN;

   return (gotShort>=shortN && gotLong>=longN);
}

bool RecentEAStats(int shortN,int longN,
                   double &wrShort,double &wrLong,double &pnlShort,
                   double &wrAsia,double &wrLondon,double &wrNY,
                   int &gotShort,int &gotLong)
{
   wrShort=0; wrLong=0; pnlShort=0;
   wrAsia=0; wrLondon=0; wrNY=0;
   gotShort=0; gotLong=0;

   datetime from=0;
   datetime to=TimeCurrent();
   if(!HistorySelect(from,to))
      return false;

   int total=HistoryDealsTotal();
   int shortWins=0,longWins=0;
   int aN=0,aW=0,lN=0,lW=0,nN=0,nW=0;
   int sessTarget=MathMax(shortN,20);

   for(int i=total-1;i>=0;i--)
   {
      ulong d=HistoryDealGetTicket(i);
      if(!IsOurClosedDeal(d)) continue;

      double profit=HistoryDealGetDouble(d,DEAL_PROFIT)
                   +HistoryDealGetDouble(d,DEAL_SWAP)
                   +HistoryDealGetDouble(d,DEAL_COMMISSION);

      if(gotLong<longN)
      {
         gotLong++;
         if(profit>0) longWins++;
      }

      if(gotShort<shortN)
      {
         gotShort++;
         pnlShort+=profit;
         if(profit>0) shortWins++;
      }

      string sess=DealSessionFromComment(HistoryDealGetString(d,DEAL_COMMENT));
      if(sess=="ASIA" && aN<sessTarget){aN++; if(profit>0)aW++;}
      if(sess=="LONDON" && lN<sessTarget){lN++; if(profit>0)lW++;}
      if(sess=="NY" && nN<sessTarget){nN++; if(profit>0)nW++;}

      if(gotLong>=longN && gotShort>=shortN &&
         aN>=sessTarget && lN>=sessTarget && nN>=sessTarget)
         break;
   }

   if(gotShort>0) wrShort=100.0*shortWins/gotShort;
   if(gotLong>0)  wrLong =100.0*longWins/gotLong;
   if(aN>0) wrAsia=100.0*aW/aN;
   if(lN>0) wrLondon=100.0*lW/lN;
   if(nN>0) wrNY=100.0*nW/nN;

   return gotShort>0;
}

bool CurrentRegimeIndicators(double &atrRatio,double &emaSepRatio,double &emaSlope)
{
   atrRatio=0; emaSepRatio=0; emaSlope=0;

   if(g_regimeATRHandle==INVALID_HANDLE ||
      g_emaHandle==INVALID_HANDLE ||
      g_regimeEMA200Handle==INVALID_HANDLE)
      return false;

   int atrBars=MathMax(RegimeATRBaselineBars,2);
   int emaBars=MathMax(RegimeEMABaselineBars,2);
   int need=MathMax(atrBars,emaBars)+2;

   double atr[],e50[],e200[];
   ArraySetAsSeries(atr,true);
   ArraySetAsSeries(e50,true);
   ArraySetAsSeries(e200,true);

   if(CopyBuffer(g_regimeATRHandle,0,0,need,atr)<need) return false;
   if(CopyBuffer(g_emaHandle,0,0,need,e50)<need) return false;
   if(CopyBuffer(g_regimeEMA200Handle,0,0,need,e200)<need) return false;

   double atrBase=0;
   for(int i=1;i<=atrBars;i++) atrBase+=atr[i];
   atrBase/=atrBars;
   if(atrBase>0) atrRatio=atr[0]/atrBase;

   double sepNow=MathAbs(e50[0]-e200[0]);
   double sepBase=0;
   for(int i=1;i<=emaBars;i++)
      sepBase+=MathAbs(e50[i]-e200[i]);
   sepBase/=emaBars;
   if(sepBase>0) emaSepRatio=sepNow/sepBase;

   int slopeBars=MathMin(20,need-1);
   emaSlope=e50[0]-e50[slopeBars];
   return true;
}

string RegimeName(double wr20,double wr60,double atrRatio,double emaSepRatio)
{
   // Historical monitor thresholds from the journal study.
   // GREEN requires recent EA behavior to remain healthy.
   bool extremeVol=(atrRatio>0 && (atrRatio<0.70 || atrRatio>1.50));
   bool contracted=(emaSepRatio>0 && emaSepRatio<0.70);

   if(wr20<45.0 || (wr60>0 && wr60<45.0))
      return "RED";

   if(wr20>=50.0 && wr60>=55.0 && !extremeVol && !contracted)
      return "GREEN";

   return "YELLOW";
}

color RegimeColor(const string regime)
{
   if(regime=="GREEN") return clrLime;
   if(regime=="RED") return clrTomato;
   return clrGold;
}


string BoolText(bool v){ return v ? "ON" : "OFF"; }

int CountSessionPositions(ENUM_S2_SESSION sess,double &floating)
{
   int count=0;
   floating=0.0;
   string tag=SessionTag(sess);

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=MagicNumber) continue;

      string c=PositionGetString(POSITION_COMMENT);
      if(StringFind(c,tag)!=0) continue;

      count++;
      floating += PositionGetDouble(POSITION_PROFIT);
   }
   return count;
}

int CountSessionPending(ENUM_S2_SESSION sess)
{
   int count=0;
   string tag=SessionTag(sess);

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      ulong ticket=OrderGetTicket(i);
      if(ticket==0) continue;
      if(OrderGetString(ORDER_SYMBOL)!=_Symbol) continue;
      if(OrderGetInteger(ORDER_MAGIC)!=MagicNumber) continue;

      string c=OrderGetString(ORDER_COMMENT);
      if(StringFind(c,tag)!=0) continue;

      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      if(type==ORDER_TYPE_BUY_STOP || type==ORDER_TYPE_SELL_STOP ||
         type==ORDER_TYPE_BUY_LIMIT || type==ORDER_TYPE_SELL_LIMIT ||
         type==ORDER_TYPE_BUY_STOP_LIMIT || type==ORDER_TYPE_SELL_STOP_LIMIT)
         count++;
   }
   return count;
}

string SessionStatusText(ENUM_S2_SESSION sess,datetime now)
{
   datetime day=StartOfDay(now),s,e;
   ComputeSessionWindow(sess,day,s,e);

   double fp=0.0;
   int pos=CountSessionPositions(sess,fp);
   int pend=CountSessionPending(sess);

   if(pos>0)
      return StringFormat("OPEN x%d  Float %.2f",pos,fp);
   if(pend>0)
      return StringFormat("PENDING x%d",pend);
   if(HasOpenedTagToday(sess,day))
      return "DONE";
   if(now<s)
      return "WAITING";
   if(now>=s && now<e)
      return "MISSED / NO ENTRY";
   return "CLOSED";
}

string HHMM(datetime t)
{
   MqlDateTime x; TimeToStruct(t,x);
   return StringFormat("%02d:%02d",x.hour,x.min);
}

string NextSessionText(datetime now)
{
   datetime today=StartOfDay(now);
   datetime best=0;
   string name="";

   for(int d=0; d<=7; d++)
   {
      datetime day=today+d*86400;
      if(!HasMarketDataOnDay(day)) continue;

      for(int k=0;k<3;k++)
      {
         ENUM_S2_SESSION sess=(ENUM_S2_SESSION)k;
         bool enabled=(sess==S2_ASIA?EnableAsia:(sess==S2_LONDON?EnableLondon:EnableNY));
         if(!enabled) continue;

         datetime s,e;
         ComputeSessionWindow(sess,day,s,e);
         if(s<=now) continue;

         if(best==0 || s<best)
         {
            best=s;
            name=SessionName(sess);
         }
      }

      if(best>0) break;
   }

   if(best==0) return "Next: unavailable";

   long sec=(long)(best-now);
   int h=(int)(sec/3600);
   int m=(int)((sec%3600)/60);

   return StringFormat("Next: %s %s  (%dh %02dm)",name,HHMM(best),h,m);
}

void CurrentExposure(int &positions,int &orders,double &floating)
{
   positions=0;
   orders=0;
   floating=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=MagicNumber) continue;

      positions++;
      floating+=PositionGetDouble(POSITION_PROFIT);
   }

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      ulong ticket=OrderGetTicket(i);
      if(ticket==0) continue;
      if(OrderGetString(ORDER_SYMBOL)!=_Symbol) continue;
      if(OrderGetInteger(ORDER_MAGIC)!=MagicNumber) continue;
      orders++;
   }
}

string TradingModeText()
{
   if(StopOrdersOnly) return "STOP ORDERS ONLY";
   if(UseSameDirectionStopOrder) return "MARKET + STOP";
   return "MARKET ENTRY";
}

void UpdateRegimePanel()
{
   if(!ShowRegimePanel)
   {
      DeleteRegimePanel();
      return;
   }

   EnsureRegimePanelBackground();

   int shortN=MathMax(RegimeShortTrades,1);
   int longN=MathMax(RegimeLongTrades,shortN);

   double wr20,wr60,pnl20,wrA,wrL,wrN;
   int got20,got60;
   bool liveOk=RecentEAStats(shortN,longN,wr20,wr60,pnl20,wrA,wrL,wrN,got20,got60);
   string statsSource="LIVE";

   if((!liveOk || got20<shortN || got60<longN) && UseHistoricalRegimeBackfill)
   {
      double h20,h60,hA,hL,hN;
      int hg20,hg60;
      if(HistoricalStrategyStats(shortN,longN,h20,h60,hA,hL,hN,hg20,hg60))
      {
         wr20=h20; wr60=h60;
         wrA=hA; wrL=hL; wrN=hN;
         got20=hg20; got60=hg60;
         pnl20=0.0;
         statsSource="HIST";
      }
   }

   double atrRatio,emaSepRatio,emaSlope;
   bool indOk=CurrentRegimeIndicators(atrRatio,emaSepRatio,emaSlope);

   string regime="WAITING";
   if(got20>=shortN && got60>=longN)
      regime=RegimeName(wr20,wr60,atrRatio,emaSepRatio);

   color rc=(regime=="WAITING")?clrSilver:RegimeColor(regime);

   int x=PanelX+10;
   int y=PanelY+8;
   int dy=18;

   SetPanelLabel("TITLE","SESSION 2 EA DASHBOARD",x,y,11,clrWhite); y+=23;
   SetPanelLabel("MODE","Mode: "+TradingModeText(),x,y,9,clrAqua); y+=dy;

   string accCur=AccountInfoString(ACCOUNT_CURRENCY);
   SetPanelLabel("RISK",StringFormat("Risk: %.2f %s | SL: %s x%.2f",
                 SheetRiskAmount,accCur,BoolText(UseStopLoss),SL_Multiplier),
                 x,y,9,clrWhite); y+=dy;

   SetPanelLabel("STOPCFG",StringFormat("Stop order: %s | Dist x%.2f | Lot x%.2f",
                 BoolText(UseSameDirectionStopOrder || StopOrdersOnly),
                 StopOrderDistanceMultiplier,StopOrderLotMultiplier),
                 x,y,8,clrSilver); y+=dy;

   SetPanelLabel("STOPSL",StringFormat("Stop-order SL: %s | x%.2f",
                 BoolText(UseStopOrderSL),StopOrderSLMultiplier),
                 x,y,8,clrSilver); y+=dy+3;

   SetPanelLabel("REG","REGIME: "+regime+"  ["+statsSource+"]",x,y,11,rc); y+=dy+1;

   if(statsSource=="HIST" && g_histRangeStart>0 && g_histRangeEnd>0)
   {
      string histRange=StringFormat("HIST RANGE: %s -> %s",
                                    TimeToString(g_histRangeStart,TIME_DATE),
                                    TimeToString(g_histRangeEnd,TIME_DATE));
      SetPanelLabel("HISTRANGE",histRange,x,y,8,clrSilver); y+=dy;
   }
   else
   {
      // Remove stale HIST range text if the panel switches back to LIVE stats.
      string histObj=REGIME_PANEL_PREFIX+"HISTRANGE";
      if(ObjectFind(0,histObj)>=0) ObjectDelete(0,histObj);
   }

   string s20;
   if(statsSource=="LIVE")
      s20=StringFormat("%d WR: %.1f%% | P/L %.2f",shortN,wr20,pnl20);
   else
      s20=StringFormat("%d WR: %.1f%%",shortN,wr20);

   SetPanelLabel("WR20",s20,x,y,9,clrWhite); y+=dy;
   SetPanelLabel("WR60",StringFormat("%d WR: %.1f%%",longN,wr60),x,y,9,clrWhite); y+=dy;
   SetPanelLabel("SESSWR",StringFormat("WR  Asia %.1f | London %.1f | NY %.1f",
                 wrA,wrL,wrN),x,y,8,clrSilver); y+=dy;

   if(indOk)
   {
      SetPanelLabel("MARKET1",StringFormat("ATR ratio %.2f | EMA sep %.2f",
                    atrRatio,emaSepRatio),x,y,8,clrSilver); y+=dy;
      SetPanelLabel("MARKET2",StringFormat("EMA50 slope %.2f",emaSlope),
                    x,y,8,clrSilver); y+=dy+3;
   }
   else
   {
      SetPanelLabel("MARKET1","Market regime indicators: loading...",x,y,8,clrSilver); y+=dy+3;
   }

   datetime now=TimeCurrent();
   datetime day=StartOfDay(now);
   datetime aS,aE,lS,lE,nS,nE;
   ComputeSessionWindow(S2_ASIA,day,aS,aE);
   ComputeSessionWindow(S2_LONDON,day,lS,lE);
   ComputeSessionWindow(S2_NY,day,nS,nE);

   SetPanelLabel("STITLE","TODAY'S SESSIONS",x,y,9,clrWhite); y+=dy;
   SetPanelLabel("ASIA",StringFormat("Asia   %s-%s  %s",HHMM(aS),HHMM(aE),
                 SessionStatusText(S2_ASIA,now)),x,y,8,clrWhite); y+=dy;
   SetPanelLabel("LONDON",StringFormat("London %s-%s  %s",HHMM(lS),HHMM(lE),
                 SessionStatusText(S2_LONDON,now)),x,y,8,clrWhite); y+=dy;
   SetPanelLabel("NY",StringFormat("NY     %s-%s  %s",HHMM(nS),HHMM(nE),
                 SessionStatusText(S2_NY,now)),x,y,8,clrWhite); y+=dy+2;

   SetPanelLabel("NEXT",NextSessionText(now),x,y,9,clrAqua); y+=dy+2;

   int posCount,orderCount;
   double floating;
   CurrentExposure(posCount,orderCount,floating);

   SetPanelLabel("EXPOSURE",StringFormat("Positions %d | Pending %d | Float %.2f %s",
                 posCount,orderCount,floating,accCur),x,y,8,clrWhite); y+=dy;

   SetPanelLabel("ACCOUNT",StringFormat("Balance %.2f | Equity %.2f",
                 AccountInfoDouble(ACCOUNT_BALANCE),
                 AccountInfoDouble(ACCOUNT_EQUITY)),
                 x,y,8,clrSilver); y+=dy;

   SetPanelLabel("NOTE","Monitor only - regime does not change trades",x,y,8,clrGray);

   ChartRedraw(0);
}

//----------------------------------------------------------------------
// MT5 lifecycle
//----------------------------------------------------------------------
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(MaxDeviationPoints);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetAsyncMode(false);

   if(RequireHedgingAccount)
   {
      long mode=AccountInfoInteger(ACCOUNT_MARGIN_MODE);
      if(mode!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      {
         Print("Session2 EA requires a HEDGING account because London and NY positions can overlap.");
         return INIT_FAILED;
      }
   }

   g_emaHandle=iMA(_Symbol,PERIOD_H1,EMA_Period,0,MODE_EMA,PRICE_CLOSE);
   if(g_emaHandle==INVALID_HANDLE)
   {
      Print("Failed to create H1 EMA handle: ",GetLastError());
      return INIT_FAILED;
   }

   g_regimeATRHandle=iATR(_Symbol,PERIOD_M30,RegimeATRPeriod);
   g_regimeEMA200Handle=iMA(_Symbol,PERIOD_M30,RegimeEMA200Period,0,MODE_EMA,PRICE_CLOSE);

   if(g_regimeATRHandle==INVALID_HANDLE || g_regimeEMA200Handle==INVALID_HANDLE)
   {
      Print("Failed to create regime monitor indicator handles: ",GetLastError());
      return INIT_FAILED;
   }

   EventSetTimer(30);
   UpdateRegimePanel();

   g_audit=FileOpen("Session2_RealTrading_Audit.csv",FILE_WRITE|FILE_CSV|FILE_ANSI);
   if(g_audit!=INVALID_HANDLE)
      FileWrite(g_audit,"Time","Session","RowDate","BaseSignal","FinalSignal","SignalInfo",
                "Avg144","SLlimitSheetPips","SLpriceDistance","Lots","Fill","SL","Status","Retcode");

   Print("Session2 Exact Trading EA initialized on ",_Symbol,
         ". Simple NY/Asia/London signal rules active, 144-session market-data sizing active. Optional same-direction STOP order supported, including STOP-ORDERS-ONLY mode. Regime panel can backfill 20/60 stats from market history.");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   PrintRegimeBacktestSummary();
   DeleteRegimePanel();
   if(g_emaHandle!=INVALID_HANDLE) IndicatorRelease(g_emaHandle);
   if(g_regimeATRHandle!=INVALID_HANDLE) IndicatorRelease(g_regimeATRHandle);
   if(g_regimeEMA200Handle!=INVALID_HANDLE) IndicatorRelease(g_regimeEMA200Handle);
   if(g_audit!=INVALID_HANDLE) FileClose(g_audit);
}

void OnTick()
{
   datetime now=TimeCurrent();

   // First close any position that survived past its scheduled session end
   // because no market tick arrived exactly at the closing timestamp.
   CloseOverdueSessionPositions(now);

   ProcessSession(S2_ASIA,EnableAsia,now);
   ProcessSession(S2_LONDON,EnableLondon,now);
   ProcessSession(S2_NY,EnableNY,now);

}


void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(!TrackRegimeBacktestStats) return;
   if(trans.type!=TRADE_TRANSACTION_DEAL_ADD) return;

   ulong deal=trans.deal;
   if(deal==0) return;

   if(HistoryDealGetString(deal,DEAL_SYMBOL)!=_Symbol) return;
   if(HistoryDealGetInteger(deal,DEAL_MAGIC)!=MagicNumber) return;

   long entryType=HistoryDealGetInteger(deal,DEAL_ENTRY);
   ulong positionId=(ulong)HistoryDealGetInteger(deal,DEAL_POSITION_ID);

   double netPart=HistoryDealGetDouble(deal,DEAL_PROFIT)
                 +HistoryDealGetDouble(deal,DEAL_SWAP)
                 +HistoryDealGetDouble(deal,DEAL_COMMISSION);

   if(entryType==DEAL_ENTRY_IN)
   {
      int idx=FindTrackedPosition(positionId);
      if(idx<0)
      {
         string regime=CurrentRegimeForTracking();
         idx=AddTrackedPosition(positionId,RegimeCodeFromName(regime));
      }
      g_regPosPnl[idx]+=netPart;
   }
   else if(entryType==DEAL_ENTRY_OUT || entryType==DEAL_ENTRY_OUT_BY)
   {
      int idx=FindTrackedPosition(positionId);

      // Normally the entry deal was seen already. If MT5 attached the EA after
      // a position existed, classify it now as a safe fallback.
      if(idx<0)
      {
         string regime=CurrentRegimeForTracking();
         idx=AddTrackedPosition(positionId,RegimeCodeFromName(regime));
      }

      g_regPosPnl[idx]+=netPart;
      FinalizeRegimePosition(idx);
   }
}

void OnTimer()
{
   UpdateRegimePanel();
}
