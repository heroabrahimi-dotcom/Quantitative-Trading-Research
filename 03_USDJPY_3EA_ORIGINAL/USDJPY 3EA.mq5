#property strict
#include <Trade/Trade.mqh>

CTrade trade;

// Leave blank to automatically use the Strategy Tester / chart symbol.
// So if tester symbol = USDJPY_DUKA_CLEAN, the EA uses USDJPY_DUKA_CLEAN.
input string InpSymbol = "USDJPY.a";
input double InpLots = 0.10;
input ulong InpMagic = 26100008;
input bool InpTradeAsia = true;
input bool InpTradeLondon = true;
input bool InpTradeNY = true;

input group "=== Stop-loss / risk sizing ==="
input double SheetRiskAmount = 600.0;       // risk amount used for lot sizing
input bool   UseStopLoss = true;            // false = current no-SL behavior
input double SL_Multiplier = 1.0;           // 1.0 = original avg*2 SL; 1.5 = 50% wider; 2.0 = twice as wide
input int    LookbackSessions = 144;         // same 144-session concept as NAS100
input double SheetPipsPerPriceUnit = 100.0; // USDJPY: 1.00 price unit = 100 pips

#define T_NY 0
#define T_ASIA 1
#define T_LONDON 2

string RULE_NY_C1 = "B1=B2";
string RULE_NY_C2 = "B2=B3";
string RULE_NY_A0 = "P3";
string RULE_NY_A1 = "MAJ_I123";
string RULE_NY_A2 = "REV_P2";
string RULE_NY_A3 = "I3";

string RULE_ASIA_C1 = "B2=BUY";
string RULE_ASIA_C2 = "I1=P1";
string RULE_ASIA_A0 = "REV_P3";
string RULE_ASIA_A1 = "B1";
string RULE_ASIA_A2 = "REV_B3";
string RULE_ASIA_A3 = "REV_I3";

string RULE_LONDON_C1 = "B2=I2";
string RULE_LONDON_C2 = "I2=I3";
string RULE_LONDON_A0 = "P3";
string RULE_LONDON_A1 = "REV_P3";
string RULE_LONDON_A2 = "REV_P1";
string RULE_LONDON_A3 = "B1";

datetime g_lastAsia=0, g_lastLondon=0, g_lastNY=0;

string TradeSymbol()
{
   if(InpSymbol == "")
      return _Symbol;

   return InpSymbol;
}

datetime DayStart(datetime t)
{
   MqlDateTime s;
   TimeToStruct(t,s);

   s.hour=0;
   s.min=0;
   s.sec=0;

   return StructToTime(s);
}

datetime MakeTime(datetime day,int hour,int minute)
{
   MqlDateTime s;
   TimeToStruct(day,s);

   s.hour=hour;
   s.min=minute;
   s.sec=0;

   return StructToTime(s);
}

int DaysInMonth(int year,int month)
{
   if(month==2)
      return ((year%4==0 && year%100!=0) || year%400==0) ? 29 : 28;

   if(month==4 || month==6 || month==9 || month==11)
      return 30;

   return 31;
}

datetime NthSunday(int year,int month,int nth)
{
   MqlDateTime s;
   ZeroMemory(s);

   s.year=year;
   s.mon=month;
   s.day=1;

   datetime first=StructToTime(s);

   TimeToStruct(first,s);

   int firstSunday=1 + ((7-s.day_of_week)%7);

   s.day=firstSunday + 7*(nth-1);
   s.hour=0;
   s.min=0;
   s.sec=0;

   return StructToTime(s);
}

datetime LastSunday(int year,int month)
{
   MqlDateTime s;
   ZeroMemory(s);

   s.year=year;
   s.mon=month;
   s.day=DaysInMonth(year,month);

   datetime last=StructToTime(s);

   TimeToStruct(last,s);

   s.day -= s.day_of_week;
   s.hour=0;
   s.min=0;
   s.sec=0;

   return StructToTime(s);
}

// London/UK daylight-saving period.
// For trading weekdays this day-level calculation is sufficient.
bool IsLondonDST(datetime day)
{
   MqlDateTime s;
   TimeToStruct(day,s);

   datetime start=LastSunday(s.year,3);
   datetime finish=LastSunday(s.year,10);

   return day>=start && day<finish;
}

// US daylight-saving period.
bool IsUSDST(datetime day)
{
   MqlDateTime s;
   TimeToStruct(day,s);

   datetime start=NthSunday(s.year,3,2);
   datetime finish=NthSunday(s.year,11,1);

   return day>=start && day<finish;
}

// =====================================================
// SESSION TIMES BELOW USE PEPPERSTONE SERVER TIME.
// Pepperstone is UTC+2 in European winter and UTC+3
// during European daylight-saving time.
// =====================================================

int ServerUTCOffset(datetime day)
{
   return IsLondonDST(day) ? 3 : 2;
}

void SessionBounds(datetime day,int sess,datetime &start,datetime &finish)
{
   day=DayStart(day);
   int off=ServerUTCOffset(day);

   // Asia: 00:00 -> 06:00 UTC.
   if(sess==T_ASIA)
   {
      start  = MakeTime(day,off,0);
      finish = MakeTime(day,off+6,0);
      return;
   }

   // London local 08:30 -> 16:30.
   // Because Pepperstone changes UTC offset with Europe,
   // this is 10:30 -> 18:30 server time year-round.
   if(sess==T_LONDON)
   {
      start  = MakeTime(day,10,30);
      finish = MakeTime(day,18,30);
      return;
   }

   // New York local 09:30 -> 16:00.
   // Convert US DST UTC times into Pepperstone server time.
   bool us=IsUSDST(day);
   int openUTC =(us ? 13 : 14)*60+30;
   int closeUTC=(us ? 20 : 21)*60;
   int openServer =openUTC +off*60;
   int closeServer=closeUTC+off*60;

   start  = MakeTime(day,(openServer/60)%24,openServer%60)
            + (openServer>=1440 ? 86400 : 0);
   finish = MakeTime(day,(closeServer/60)%24,closeServer%60)
            + (closeServer>=1440 ? 86400 : 0);
}

bool HasData(datetime day)
{
   string symbol=TradeSymbol();

   MqlRates r[];
   ArraySetAsSeries(r,false);

   datetime a=MakeTime(DayStart(day),0,0);
   datetime b=a+86399;

   return CopyRates(symbol,PERIOD_M30,a,b,r)>0;
}

datetime PrevTradingDay(datetime day,int back)
{
   datetime d=DayStart(day);

   if(back<=0)
      return d;

   int found=0;

   for(int k=0;k<20 && found<back;k++)
   {
      d-=86400;

      if(HasData(d))
         found++;
   }

   return d;
}

int SessionDirection(datetime day,int sess)
{
   string symbol=TradeSymbol();

   datetime a,b;
   SessionBounds(day,sess,a,b);

   MqlRates r[];
   ArraySetAsSeries(r,false);

   int n=CopyRates(symbol,PERIOD_M30,a,b-1,r);

   if(n<2)
      return 0;

   double op=r[0].open;
   double cl=r[n-1].close;

   if(cl>op)
      return 1;

   if(cl<op)
      return -1;

   return 0;
}


// =====================================================
// NAS100-STYLE STOP / RISK-SIZING CONCEPT
// Signal rules are NOT changed.
// For each session:
//   1) reconstruct previous session ranges,
//   2) average the prior LookbackSessions values,
//   3) SL limit = avg * 2,
//   4) choose lot size so an SL hit is approximately SheetRiskAmount.
// If UseStopLoss=false, the same calculated lot size is used but no SL is sent.
// =====================================================
bool GetSessionRange(datetime day,int sess,double &buyPips,double &sellPips)
{
   string symbol=TradeSymbol();

   datetime a,b;
   SessionBounds(day,sess,a,b);

   MqlRates r[];
   ArraySetAsSeries(r,false);

   int n=CopyRates(symbol,PERIOD_M30,a,b-1,r);
   if(n<=0)
      return false;

   double op=r[0].open;
   double hi=r[0].high;
   double lo=r[0].low;

   for(int i=1;i<n;i++)
   {
      if(r[i].high>hi) hi=r[i].high;
      if(r[i].low<lo)  lo=r[i].low;
   }

   buyPips =(hi-op)*SheetPipsPerPriceUnit;
   sellPips=(op-lo)*SheetPipsPerPriceUnit;

   return true;
}

bool ComputePreviousAverage(int sess,datetime currentSessionStart,
                            double &avgPips,int &count,string &info)
{
   int want=LookbackSessions;
   if(want<=0) want=144;

   double sum=0.0;
   count=0;

   datetime base=DayStart(currentSessionStart);

   for(int back=1;back<1200 && count<want;back++)
   {
      datetime d=PrevTradingDay(base,back);

      double bp=0.0,sp=0.0;
      if(!GetSessionRange(d,sess,bp,sp))
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

double NormalizePriceToTick(string symbol,double price)
{
   double tick=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   if(tick>0.0)
      price=MathRound(price/tick)*tick;

   return NormalizeDouble(price,digits);
}

int VolumeDigits(double step)
{
   int d=0;
   while(d<8 && MathAbs(step-NormalizeDouble(step,d))>1e-12)
      d++;
   return d;
}

double NormalizeVolumeNearest(string symbol,double lots)
{
   double step=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double mn=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double mx=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);

   if(step<=0.0) step=0.01;

   lots=MathRound(lots/step)*step;
   lots=MathMax(mn,MathMin(mx,lots));

   return NormalizeDouble(lots,VolumeDigits(step));
}

bool LotsForRisk(string symbol,int sig,double entry,double sl,
                 double risk,double &lots,double &oneLotLoss)
{
   ENUM_ORDER_TYPE type=(sig>0)?ORDER_TYPE_BUY:ORDER_TYPE_SELL;

   double pnl=0.0;
   if(!OrderCalcProfit(type,symbol,1.0,entry,sl,pnl))
      return false;

   oneLotLoss=MathAbs(pnl);
   if(oneLotLoss<=0.0)
      return false;

   lots=NormalizeVolumeNearest(symbol,risk/oneLotLoss);

   return lots>0.0;
}

int RefValue(string ref,datetime day,int target)
{
   string col=StringSubstr(ref,0,1);
   int lag=(int)StringToInteger(StringSubstr(ref,1));

   datetime d=day;
   int sess=T_NY;

   if(target==T_NY)
   {
      if(col=="B")
      {
         d=PrevTradingDay(day,lag);
         sess=T_NY;
      }
      else if(col=="I")
      {
         d=PrevTradingDay(day,lag-1);
         sess=T_ASIA;
      }
      else
      {
         d=PrevTradingDay(day,lag-1);
         sess=T_LONDON;
      }
   }
   else
   {
      if(col=="B")
      {
         d=PrevTradingDay(day,lag+1);
         sess=T_NY;
      }
      else if(col=="I")
      {
         d=PrevTradingDay(day,lag);
         sess=T_ASIA;
      }
      else
      {
         d=PrevTradingDay(day,lag);
         sess=T_LONDON;
      }
   }

   return SessionDirection(d,sess);
}

bool EvalCond(string c,datetime day,int target,bool &ok)
{
   int p=StringFind(c,"=");

   if(p<1)
   {
      ok=false;
      return false;
   }

   string left=StringSubstr(c,0,p);
   string right=StringSubstr(c,p+1);

   int a=RefValue(left,day,target);

   if(a==0)
   {
      ok=false;
      return false;
   }

   if(right=="BUY")
   {
      ok=true;
      return a==1;
   }

   if(right=="SELL")
   {
      ok=true;
      return a==-1;
   }

   int b=RefValue(right,day,target);

   if(b==0)
   {
      ok=false;
      return false;
   }

   ok=true;

   return a==b;
}

int EvalAction(string a,datetime day,int target,bool &ok)
{
   if(a=="BUY")
   {
      ok=true;
      return 1;
   }

   if(a=="SELL")
   {
      ok=true;
      return -1;
   }

   if(StringFind(a,"REV_")==0)
   {
      int v=RefValue(StringSubstr(a,4),day,target);

      ok=(v!=0);

      return -v;
   }

   if(StringFind(a,"MAJ_")==0)
   {
      string c=StringSubstr(a,4,1);

      int v1=RefValue(c+"1",day,target);
      int v2=RefValue(c+"2",day,target);
      int v3=RefValue(c+"3",day,target);

      if(v1==0 || v2==0 || v3==0)
      {
         ok=false;
         return 0;
      }

      ok=true;

      return (v1+v2+v3>=1) ? 1 : -1;
   }

   int v=RefValue(a,day,target);

   ok=(v!=0);

   return v;
}

int EvalRule(
   datetime day,
   int target,
   string c1,
   string c2,
   string a0,
   string a1,
   string a2,
   string a3
)
{
   bool ok1=false;
   bool ok2=false;
   bool oka=false;

   bool x=EvalCond(c1,day,target,ok1);
   bool y=EvalCond(c2,day,target,ok2);

   if(!ok1 || !ok2)
      return 0;

   string act;

   if(x)
      act = y ? a0 : a1;
   else
      act = y ? a2 : a3;

   int s=EvalAction(act,day,target,oka);

   return oka ? s : 0;
}

int SignalFor(datetime day,int target)
{
   if(target==T_NY)
      return EvalRule(
         day,target,
         RULE_NY_C1,
         RULE_NY_C2,
         RULE_NY_A0,
         RULE_NY_A1,
         RULE_NY_A2,
         RULE_NY_A3
      );

   if(target==T_ASIA)
      return EvalRule(
         day,target,
         RULE_ASIA_C1,
         RULE_ASIA_C2,
         RULE_ASIA_A0,
         RULE_ASIA_A1,
         RULE_ASIA_A2,
         RULE_ASIA_A3
      );

   return EvalRule(
      day,target,
      RULE_LONDON_C1,
      RULE_LONDON_C2,
      RULE_LONDON_A0,
      RULE_LONDON_A1,
      RULE_LONDON_A2,
      RULE_LONDON_A3
   );
}

string SessName(int s)
{
   if(s==T_ASIA)
      return "ASIA";

   if(s==T_LONDON)
      return "LONDON";

   return "NY";
}

bool OpenTrade(int sess,datetime day)
{
   string symbol=TradeSymbol();

   int sig=SignalFor(day,sess);

   if(sig==0)
   {
      Print(
         "NO SIGNAL ",
         SessName(sess),
         " day=",
         TimeToString(day)
      );

      return false;
   }

   trade.SetExpertMagicNumber(InpMagic);

   string cm="Q30_"+SessName(sess);

   datetime sessionStart,sessionEnd;
   SessionBounds(day,sess,sessionStart,sessionEnd);

   // Same stop/risk concept used by the NAS100 EA.
   double avg=0.0;
   int count=0;
   string avgInfo;

   if(!ComputePreviousAverage(sess,sessionStart,avg,count,avgInfo))
   {
      Print(
         "SIZING UNAVAILABLE ",
         SessName(sess),
         " ",
         avgInfo
      );

      return false;
   }

   double slLimitPips=avg*2.0;
   double baseDistance=slLimitPips/SheetPipsPerPriceUnit;
   double mult=(SL_Multiplier>0.0)?SL_Multiplier:1.0;
   double distance=baseDistance*mult;

   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double entry=(sig>0)?ask:bid;

   double sl=NormalizePriceToTick(
      symbol,
      sig>0 ? entry-distance : entry+distance
   );

   if(UseStopLoss)
   {
      double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
      double minDist=(double)SymbolInfoInteger(
         symbol,
         SYMBOL_TRADE_STOPS_LEVEL
      )*point;

      if(MathAbs(entry-sl)+1e-12<minDist)
      {
         Print(
            "SL INSIDE BROKER MINIMUM ",
            SessName(sess)
         );

         return false;
      }
   }

   double risk=(SheetRiskAmount>0.0)?SheetRiskAmount:600.0;
   double lots=0.0;
   double oneLotLoss=0.0;

   if(!LotsForRisk(symbol,sig,entry,sl,risk,lots,oneLotLoss))
   {
      Print(
         "LOT CALCULATION FAILED ",
         SessName(sess)
      );

      return false;
   }

   double orderSL=UseStopLoss ? sl : 0.0;

   bool ok;

   if(sig>0)
      ok=trade.Buy(lots,symbol,0,orderSL,0,cm);
   else
      ok=trade.Sell(lots,symbol,0,orderSL,0,cm);

   if(!ok)
   {
      Print(
         "OPEN FAILED ",
         symbol,
         " ",
         cm,
         " ret=",
         trade.ResultRetcode(),
         " ",
         trade.ResultRetcodeDescription()
      );
   }
   else
   {
      PrintFormat(
         "OPENED %s %s symbol=%s | avg=%.6f SLlim=%.6f dist=%.5f lots=%.2f fill=%.5f SL=%.5f",
         cm,
         sig>0 ? "BUY" : "SELL",
         symbol,
         avg,
         slLimitPips,
         distance,
         lots,
         trade.ResultPrice(),
         orderSL
      );
   }

   return ok;
}

void CloseExpired()
{
   string symbol=TradeSymbol();

   datetime now=TimeCurrent();

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);

      if(ticket==0)
         continue;

      if(PositionGetString(POSITION_SYMBOL)!=symbol)
         continue;

      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagic)
         continue;

      string cm=PositionGetString(POSITION_COMMENT);

      int sess=-1;

      if(StringFind(cm,"Q30_ASIA")>=0)
         sess=T_ASIA;
      else if(StringFind(cm,"Q30_LONDON")>=0)
         sess=T_LONDON;
      else if(StringFind(cm,"Q30_NY")>=0)
         sess=T_NY;

      if(sess<0)
         continue;

      datetime opened=
         (datetime)PositionGetInteger(POSITION_TIME);

      datetime a,b;

      SessionBounds(
         DayStart(opened),
         sess,
         a,
         b
      );

      if(now>=b)
      {
         trade.SetExpertMagicNumber(InpMagic);

         if(trade.PositionClose(ticket))
         {
            Print(
               "CLOSED ",
               cm,
               " ticket=",
               ticket,
               " expectedClose=",
               TimeToString(b,TIME_DATE|TIME_MINUTES),
               " actualClose=",
               TimeToString(now,TIME_DATE|TIME_SECONDS),
               " holdSeconds=",
               (long)(now-opened)
            );
         }
         else
         {
            Print(
               "CLOSE FAILED ticket=",
               ticket,
               " ret=",
               trade.ResultRetcode(),
               " ",
               trade.ResultRetcodeDescription()
            );
         }
      }
   }
}

void MaybeOpen(
   datetime day,
   int sess,
   bool enabled,
   datetime &lastKey
)
{
   if(!enabled)
      return;

   datetime a,b;

   SessionBounds(day,sess,a,b);

   datetime now=TimeCurrent();

   // Only allow opening during the first M30
   // candle of the session.
   if(now<a || now>=a+1800)
      return;

   if(lastKey==a)
      return;

   lastKey=a;

   OpenTrade(sess,day);
}

int OnInit()
{
   string symbol=TradeSymbol();

   if(!SymbolSelect(symbol,true))
   {
      Print("Cannot select symbol: ",symbol);
      return INIT_FAILED;
   }

   trade.SetExpertMagicNumber(InpMagic);

   Print("======================================");
   Print("Q30 EA STARTED");
   Print("Symbol: ",symbol);
   Print("TIME BASIS: PEPPERSTONE SERVER TIME");
   Print("ASIA: 00:00 -> 06:00 UTC converted to server time");
   Print("LONDON: 10:30 -> 18:30 server time");
   Print("LONDON UTC conversion follows Pepperstone EU DST");
   Print("NY: 09:30 -> 16:00 New York local");
   Print("NY conversion follows US DST + server offset");
   Print("======================================");

   return INIT_SUCCEEDED;
}

void OnTick()
{
   datetime now=TimeCurrent();
   datetime day=DayStart(now);

   CloseExpired();

   MaybeOpen(
      day,
      T_ASIA,
      InpTradeAsia,
      g_lastAsia
   );

   MaybeOpen(
      day,
      T_LONDON,
      InpTradeLondon,
      g_lastLondon
   );

   MaybeOpen(
      day,
      T_NY,
      InpTradeNY,
      g_lastNY
   );
}