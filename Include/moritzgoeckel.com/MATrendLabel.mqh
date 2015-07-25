#property copyright "Copyright 2015, Moritz Göckel"
#property link      "https://www.moritzgoeckel.com"
#property version   "1.00"

class MATrendLabel
{
   private:
   
   public:
      enum ENUM_ADVICE{
         ADVICE_BUY,
         ADVICE_SELL,
         ADVICE_NONE
      };
   
      MATrendLabel();
      ~MATrendLabel();
      ENUM_ADVICE getMASignal(ENUM_TIMEFRAMES timeframe, int ma_period);
      void printTrends();
};

MATrendLabel::MATrendLabel()
{
   
}

MATrendLabel::~MATrendLabel()
{
   ObjectDelete(0, "MyLabel1");
}

void MATrendLabel::printTrends(){
   string output = "";
   
   ENUM_ADVICE minute = getMASignal(PERIOD_M1, 10);
   output += "m: " + (minute == ADVICE_BUY ? "L" : "S") + " ";
   
   ENUM_ADVICE hour = getMASignal(PERIOD_M15, 4);
   output += "- H: " + (hour == ADVICE_BUY ? "L" : "S") + " ";
   
   ENUM_ADVICE day = getMASignal(PERIOD_H1, 24);
   output += "- D: " + (day == ADVICE_BUY ? "L" : "S") + " ";
   
   ENUM_ADVICE week = getMASignal(PERIOD_D1, 7);
   output += "- W: " + (week == ADVICE_BUY ? "L" : "S") + " ";
   
   ENUM_ADVICE month = getMASignal(PERIOD_W1, 4);
   output += "- M: " + (month == ADVICE_BUY ? "L" : "S") + " ";
   
   if(ObjectFind(0, "MyLabel1") < 0)
   {
      ObjectCreate(0, "MyLabel1", OBJ_LABEL, 0,0,0);
      ObjectSetInteger(0, "MyLabel1", OBJPROP_CORNER, 1);
      ObjectSetInteger(0, "MyLabel1", OBJPROP_XDISTANCE, 20);
      ObjectSetInteger(0, "MyLabel1", OBJPROP_YDISTANCE, 70);
      
      ObjectSetInteger(0, "MyLabel1", OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, "MyLabel1", OBJPROP_FONTSIZE, 20);
      ObjectSetString(0, "MyLabel1", OBJPROP_FONT, "Arial");
   }
   ObjectSetString(0, "MyLabel1", OBJPROP_TEXT, output);
}

ENUM_ADVICE MATrendLabel::getMASignal(ENUM_TIMEFRAMES timeframe, int ma_period){
   MqlTick tick;
   SymbolInfoTick(_Symbol, tick);

   int handle = iMA(_Symbol, timeframe, ma_period, 0, MODE_SMA, PRICE_MEDIAN);
   double ma[];
   ArraySetAsSeries(ma, true);
   CopyBuffer(handle, 0, 0, 10, ma);
   
   if(tick.ask > ma[0])
      return ADVICE_BUY;
   if(tick.ask < ma[0])
      return ADVICE_SELL;
      
   return ADVICE_NONE;
}