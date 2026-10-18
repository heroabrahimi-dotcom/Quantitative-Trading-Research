#property strict
#include <Trade/Trade.mqh>

CTrade trade;

input string InpSymbol = "US500.a";
input double InpLots = 0.10;
input ulong InpMagic = 26100004;
input bool InpTradeAsia = true;
input bool InpTradeLondon = true;
input bool InpTradeNY = true;

input group "=== Risk / stop-loss sizing ==="
input bool   UseRiskSizing = true;      // true = calculate lots from risk amount
input double SheetRiskAmount = 600.0;   // account-currency risk per trade
input bool   UseStopLoss = true;        // false = keep trade without SL
input double SL_Multiplier = 1.0;       // 1.0 = base avg-session SL; 1.5 = 50% wider; 2.0 = twice as wide
input int    LookbackSessions = 144;     // previous completed same-session ranges

#define T_NY 0
#define T_ASIA 1
#define T_LONDON 2

// =====================================================
// ORIGINAL SIGNAL RULES -- UNCHANGED
// =====================================================
string RULE_NY_C1 = "B2=P2";
string RULE_NY_C2 = "I1=I2";
string RULE_NY_A0 = "BUY";
string RULE_NY_A1 = "REV_I1";
string RULE_NY_A2 = "REV_B2";
string RULE_NY_A3 = "I1";

string RULE_ASIA_C1 = "B2=B3";
string RULE_ASIA_C2 = "P1=P2";
string RULE_ASIA_A0 = "REV_I1";
string RULE_ASIA_A1 = "REV_I3";
string RULE_ASIA_A2 = "B1";
string RULE_ASIA_A3 = "REV_B1";

string RULE_LONDON_C1 = "P1=BUY";
string RULE_LONDON_C2 = "P2=BUY";
string RULE_LONDON_A0 = "B2";
string RULE_LONDON_A1 = "REV_B3";
string RULE_LONDON_A2 = "REV_I1";
string RULE_LONDON_A3 = "REV_B1";

datetime g_lastAsia=0, g_lastLondon=0, g_lastNY=0;

datetime DayStart(datetime t)
{
   MqlDateTime s; TimeToStruct(t,s);
   s.hour=0; s.min=0; s.sec=0;
   return StructToTime(s);
}

datetime MakeTime(datetime day,int hour,int minute)
{
   MqlDateTime s; TimeToStruct(day,s);
   s.hour=hour; s.min=minute; s.sec=0;
   return StructToTime(s);
}

int DaysInMonth(int year,int month)
{
   if(month==2) return ((year%4==0 && year%100!=0) || year%400==0) ? 29 : 28;
   if(month==4 || month==6 || month==9 || month==11) return 30;
   return 31;
}

datetime NthSunday(int year,int month,int nth)
{
   MqlDateTime s; ZeroMemory(s);
   s.year=year; s.mon=month; s.day=1;
   datetime first=StructToTime(s); TimeToStruct(first,s);
   int firstSunday=1 + ((7-s.day_of_week)%7);
   s.day=firstSunday + 7*(nth-1);
   return StructToTime(s);
}

datetime LastSunday(int year,int month)
{
   MqlDateTime s; ZeroMemory(s);
   s.year=year; s.mon=month; s.day=DaysInMonth(year,month);
   datetime last=StructToTime(s); TimeToStruct(last,s);
   s.day -= s.day_of_week;
   return StructToTime(s);
}

bool IsEUDST(datetime day)
{
   MqlDateTime s; TimeToStruct(day,s);
   datetime a=LastSunday(s.year,3);
   datetime b=LastSunday(s.year,10);
   return day>=a && day<b;
}

bool IsUSDST(datetime day)
{
   MqlDateTime s; TimeToStruct(day,s);
   datetime a=NthSunday(s.year,3,2);
   datetime b=NthSunday(s.year,11,1);
   return day>=a && day<b;
}

int ServerUTCOffset(datetime day)
{
   return IsEUDST(day) ? 3 : 2;
}

void SessionBounds(datetime day,int sess,datetime &start,datetime &finish)
{
   day=DayStart(day);
   int off=ServerUTCOffset(day);

   if(sess==T_ASIA)
   {
      start=MakeTime(day,off,0);
      finish=MakeTime(day,off+6,0);
      return;
   }

   if(sess==T_LONDON)
   {
      start=MakeTime(day,10,30);
      finish=MakeTime(day,18,30);
      return;
   }

   bool us=IsUSDST(day);
   int openUTC=(us ? 13 : 14)*60+30;
   int closeUTC=(us ? 20 : 21)*60;
   int openServer=openUTC+off*60;
   int closeServer=closeUTC+off*60;

   start=MakeTime(day,(openServer/60)%24,openServer%60) + (openServer>=1440 ? 86400 : 0);
   finish=MakeTime(day,(closeServer/60)%24,closeServer%60) + (closeServer>=1440 ? 86400 : 0);
}

bool HasData(datetime day)
{
   MqlRates r[]; ArraySetAsSeries(r,false);
   datetime a=MakeTime(DayStart(day),0,0), b=a+86399;
   return CopyRates(InpSymbol,PERIOD_M30,a,b,r)>0;
}

datetime PrevTradingDay(datetime day,int back)
{
   datetime d=DayStart(day);
   if(back<=0) return d;

   int found=0;
   for(int k=0;k<1200 && found<back;k++)
   {
      d-=86400;
      if(HasData(d)) found++;
   }

   return d;
}

int SessionDirection(datetime day,int sess)
{
   datetime a,b; SessionBounds(day,sess,a,b);

   MqlRates r[]; ArraySetAsSeries(r,false);
   int n=CopyRates(InpSymbol,PERIOD_M30,a,b-1,r);

   if(n<2) return 0;

   double op=r[0].open;
   double cl=r[n-1].close;

   if(cl>op) return 1;
   if(cl<op) return -1;
   return 0;
}

// =====================================================
// RISK / STOP-LOSS HELPERS
// Signal logic above and below is unchanged.
// =====================================================
bool GetSessionRange(datetime day,int sess,double &rangePrice)
{
   datetime a,b; SessionBounds(day,sess,a,b);

   MqlRates r[];
   ArraySetAsSeries(r,false);

   int n=CopyRates(InpSymbol,PERIOD_M30,a,b-1,r);
   if(n<=0) return false;

   double hi=r[0].high;
   double lo=r[0].low;

   for(int i=1;i<n;i++)
   {
      if(r[i].high>hi) hi=r[i].high;
      if(r[i].low<lo)  lo=r[i].low;
   }

   rangePrice=hi-lo;
   return rangePrice>0.0;
}

bool ComputePreviousAverageRange(int sess,datetime currentSessionStart,double &avgRange,int &count)
{
   int want=LookbackSessions;
   if(want<=0) want=144;

   double sum=0.0;
   count=0;

   datetime d=DayStart(currentSessionStart);

   for(int back=1;back<1200 && count<want;back++)
   {
      datetime pd=PrevTradingDay(d,back);

      double r=0.0;
      if(!GetSessionRange(pd,sess,r))
         continue;

      sum+=r;
      count++;
   }

   if(count<want)
      return false;

   avgRange=sum/count;
   return avgRange>0.0;
}

double NormalizePriceToTick(double price)
{
   double tick=SymbolInfoDouble(InpSymbol,SYMBOL_TRADE_TICK_SIZE);
   int digits=(int)SymbolInfoInteger(InpSymbol,SYMBOL_DIGITS);

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

double NormalizeVolumeNearest(double lots)
{
   double step=SymbolInfoDouble(InpSymbol,SYMBOL_VOLUME_STEP);
   double mn=SymbolInfoDouble(InpSymbol,SYMBOL_VOLUME_MIN);
   double mx=SymbolInfoDouble(InpSymbol,SYMBOL_VOLUME_MAX);

   if(step<=0.0) step=0.01;

   lots=MathRound(lots/step)*step;
   lots=MathMax(mn,MathMin(mx,lots));

   return NormalizeDouble(lots,VolumeDigits(step));
}

bool LotsForRisk(int sig,double entry,double sl,double risk,double &lots,double &oneLotLoss)
{
   ENUM_ORDER_TYPE type=(sig>0)?ORDER_TYPE_BUY:ORDER_TYPE_SELL;

   double pnl=0.0;
   if(!OrderCalcProfit(type,InpSymbol,1.0,entry,sl,pnl))
      return false;

   oneLotLoss=MathAbs(pnl);
   if(oneLotLoss<=0.0)
      return false;

   lots=NormalizeVolumeNearest(risk/oneLotLoss);
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
      if(col=="B") { d=PrevTradingDay(day,lag); sess=T_NY; }
      else if(col=="I") { d=PrevTradingDay(day,lag-1); sess=T_ASIA; }
      else { d=PrevTradingDay(day,lag-1); sess=T_LONDON; }
   }
   else
   {
      if(col=="B") { d=PrevTradingDay(day,lag+1); sess=T_NY; }
      else if(col=="I") { d=PrevTradingDay(day,lag); sess=T_ASIA; }
      else { d=PrevTradingDay(day,lag); sess=T_LONDON; }
   }

   return SessionDirection(d,sess);
}

bool EvalCond(string c,datetime day,int target,bool &ok)
{
   int p=StringFind(c,"=");
   if(p<1) { ok=false; return false; }

   string left=StringSubstr(c,0,p);
   string right=StringSubstr(c,p+1);

   int a=RefValue(left,day,target);
   if(a==0) { ok=false; return false; }

   if(right=="BUY") { ok=true; return a==1; }
   if(right=="SELL") { ok=true; return a==-1; }

   int b=RefValue(right,day,target);
   if(b==0) { ok=false; return false; }

   ok=true;
   return a==b;
}

int EvalAction(string a,datetime day,int target,bool &ok)
{
   if(a=="BUY") { ok=true; return 1; }
   if(a=="SELL") { ok=true; return -1; }

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

int EvalRule(datetime day,int target,string c1,string c2,string a0,string a1,string a2,string a3)
{
   bool ok1=false,ok2=false,oka=false;
   bool x=EvalCond(c1,day,target,ok1);
   bool y=EvalCond(c2,day,target,ok2);

   if(!ok1 || !ok2) return 0;

   string act = x ? (y ? a0 : a1) : (y ? a2 : a3);
   int s=EvalAction(act,day,target,oka);

   return oka ? s : 0;
}

int SignalFor(datetime day,int target)
{
   if(target==T_NY)
      return EvalRule(day,target,RULE_NY_C1,RULE_NY_C2,RULE_NY_A0,RULE_NY_A1,RULE_NY_A2,RULE_NY_A3);

   if(target==T_ASIA)
      return EvalRule(day,target,RULE_ASIA_C1,RULE_ASIA_C2,RULE_ASIA_A0,RULE_ASIA_A1,RULE_ASIA_A2,RULE_ASIA_A3);

   return EvalRule(day,target,RULE_LONDON_C1,RULE_LONDON_C2,RULE_LONDON_A0,RULE_LONDON_A1,RULE_LONDON_A2,RULE_LONDON_A3);
}

string SessName(int s)
{
   if(s==T_ASIA) return "ASIA";
   if(s==T_LONDON) return "LONDON";
   return "NY";
}

bool OpenTrade(int sess,datetime day)
{
   int sig=SignalFor(day,sess);
   if(sig==0)
      return false;

   trade.SetExpertMagicNumber(InpMagic);

   string cm="Q30_"+SessName(sess);

   double lots=NormalizeVolumeNearest(InpLots);
   double orderSL=0.0;

   // Calculate the same-session average range only when risk sizing or SL is enabled.
   if(UseRiskSizing || UseStopLoss)
   {
      datetime sessionStart,sessionEnd;
      SessionBounds(day,sess,sessionStart,sessionEnd);

      double avgRange=0.0;
      int count=0;

      if(!ComputePreviousAverageRange(sess,sessionStart,avgRange,count))
      {
         Print("Sizing unavailable ",SessName(sess),
               " only ",count,"/",LookbackSessions," prior sessions");
         return false;
      }

      double mult=(SL_Multiplier>0.0)?SL_Multiplier:1.0;
      double distance=avgRange*mult;

      double ask=SymbolInfoDouble(InpSymbol,SYMBOL_ASK);
      double bid=SymbolInfoDouble(InpSymbol,SYMBOL_BID);
      double entry=(sig>0)?ask:bid;

      double calcSL=NormalizePriceToTick(
         sig>0 ? entry-distance : entry+distance
      );

      double point=SymbolInfoDouble(InpSymbol,SYMBOL_POINT);
      double minDist=(double)SymbolInfoInteger(InpSymbol,SYMBOL_TRADE_STOPS_LEVEL)*point;

      if(MathAbs(entry-calcSL)+1e-12<minDist)
      {
         Print("SL inside broker minimum ",SessName(sess));
         return false;
      }

      if(UseRiskSizing)
      {
         double oneLotLoss=0.0;

         if(!LotsForRisk(sig,entry,calcSL,SheetRiskAmount,lots,oneLotLoss))
         {
            Print("Risk lot calculation failed ",SessName(sess));
            return false;
         }
      }

      if(UseStopLoss)
         orderSL=calcSL;

      PrintFormat(
         "Q30 %s sizing | avgRange=%.5f dist=%.5f risk=%.2f lots=%.2f SL=%.5f",
         SessName(sess),avgRange,distance,SheetRiskAmount,lots,orderSL
      );
   }

   bool ok = sig>0
             ? trade.Buy(lots,InpSymbol,0,orderSL,0,cm)
             : trade.Sell(lots,InpSymbol,0,orderSL,0,cm);

   if(!ok)
      Print("Open failed ",InpSymbol," ",cm,
            " ret=",trade.ResultRetcode()," ",
            trade.ResultRetcodeDescription());

   return ok;
}

void CloseExpired()
{
   datetime now=TimeCurrent();

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;

      if(PositionGetString(POSITION_SYMBOL)!=InpSymbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;

      string cm=PositionGetString(POSITION_COMMENT);
      int sess=-1;

      if(StringFind(cm,"Q30_ASIA")>=0) sess=T_ASIA;
      else if(StringFind(cm,"Q30_LONDON")>=0) sess=T_LONDON;
      else if(StringFind(cm,"Q30_NY")>=0) sess=T_NY;

      if(sess<0) continue;

      datetime opened=(datetime)PositionGetInteger(POSITION_TIME);
      datetime a,b;
      SessionBounds(DayStart(opened),sess,a,b);

      if(now>=b)
      {
         trade.SetExpertMagicNumber(InpMagic);

         if(!trade.PositionClose(ticket))
            Print("Close failed ticket=",ticket,
                  " ret=",trade.ResultRetcode()," ",
                  trade.ResultRetcodeDescription());
      }
   }
}

void MaybeOpen(datetime day,int sess,bool enabled,datetime &lastKey)
{
   if(!enabled) return;

   datetime a,b;
   SessionBounds(day,sess,a,b);

   datetime now=TimeCurrent();

   if(now<a || now>=a+1800) return;
   if(lastKey==a) return;

   lastKey=a;
   OpenTrade(sess,day);
}

int OnInit()
{
   if(!SymbolSelect(InpSymbol,true))
   {
      Print("Cannot select symbol: ",InpSymbol);
      return INIT_FAILED;
   }

   trade.SetExpertMagicNumber(InpMagic);
   trade.SetTypeFillingBySymbol(InpSymbol);
   trade.SetAsyncMode(false);

   return INIT_SUCCEEDED;
}

void OnTick()
{
   datetime now=TimeCurrent();
   datetime day=DayStart(now);

   CloseExpired();

   MaybeOpen(day,T_ASIA,InpTradeAsia,g_lastAsia);
   MaybeOpen(day,T_LONDON,InpTradeLondon,g_lastLondon);
   MaybeOpen(day,T_NY,InpTradeNY,g_lastNY);
}
