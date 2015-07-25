#property copyright "Copyright 2015, Moritz Göckel"
#property link      "https://www.moritzgoeckel.com"

#include <trade/trade.mqh>

class MGHelper
{
   private:
   
   public:
      enum ENUM_ADVICE{
         ADVICE_BUY,
         ADVICE_SELL,
         ADVICE_NONE
      };
   
      MGHelper();
      ~MGHelper();
      void closePositions();
      void getMA(ENUM_TIMEFRAMES timeframe, int ma_peroid, int count, double& array[]);
      double normalizePrice(double value);
      double normalizeVolume(double value);
      double calculateVolume(double Entry, double SL, double Percent);
      void trade(bool buy, double sl, double tp);
      string orderToString(MqlTradeRequest &request);
};

MGHelper::MGHelper()
{
   
}

MGHelper::~MGHelper()
{
   
}

void MGHelper::closePositions(){
   Print("Close Position");
   CTrade trade;
   while(trade.PositionClose(Symbol()) == false)
      Sleep(1000);
}

void MGHelper::getMA(ENUM_TIMEFRAMES timeframe, int ma_peroid, int count, double& array[])
{
   int handle = iMA(_Symbol, timeframe, ma_peroid, 0, MODE_SMA, PRICE_MEDIAN);
   ArraySetAsSeries(array, true);
   CopyBuffer(handle, 0, 0, count, array);
}

double MGHelper::normalizePrice(double value){
   long digits = SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
   return NormalizeDouble(value, (int)digits);
}

double MGHelper::normalizeVolume(double value)
{
   double min = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   double max = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
   
   if(value < min)
      value = min;
   if(value > max)
      value = max;
   
   value = MathRound(value / step) * step;
   
   if(step >= 0.1)
      value = NormalizeDouble(value, 1);
   else
      value = NormalizeDouble(value, 2);
   
   return value;
}

double MGHelper::calculateVolume(double Entry, double SL, double Percent) {
   double AccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double AmountToRisk = AccountBalance*Percent/100;
  
   double ValuePp = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
  
   double Difference = (Entry-SL)/_Point;
   if (Difference < 0) Difference *= -1;
   Difference = Difference*ValuePp;
  
   if(Difference == 0)
      return 0;
  
   return (AmountToRisk/Difference);
}

void MGHelper::trade(bool buy, double sl, double tp)
{
      //Normalize Pries
      sl = normalizePrice(sl);
      tp = normalizePrice(tp);

      double price;
      if(buy)
         price = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      else
         price = SymbolInfoDouble(Symbol(),SYMBOL_BID);
      
      price = NormalizeDouble(price, Digits());
      
      MqlTradeRequest orderRequest;
      MqlTradeResult orderResult;
      ZeroMemory(orderRequest);
      ZeroMemory(orderResult);
   
      orderRequest.price = price;
      
      orderRequest.action = TRADE_ACTION_DEAL;
      
      if(buy)
         orderRequest.type = ORDER_TYPE_BUY;
      else
         orderRequest.type = ORDER_TYPE_SELL;
          
      double volume = calculateVolume(price, sl, 2);
      volume = normalizeVolume(volume);
      orderRequest.volume = volume;
      
      orderRequest.symbol = Symbol();
      orderRequest.type_filling = ORDER_FILLING_FOK;
      orderRequest.sl = 0;
      orderRequest.tp = 0;
      orderRequest.deviation = 5;
      orderRequest.magic = 0;
      orderRequest.comment = "byMATrader";
      
      orderRequest.expiration = 0;
      orderRequest.type_time = ORDER_TIME_GTC;
      
      OrderSend(orderRequest, orderResult);
      
      Alert("ORDER: " + orderToString(orderRequest));
      Alert("Error: " + GetLastError());
      Alert("RETURN: " + orderResult.retcode);
      
      Print("Open: " + orderResult.retcode + " -> " + orderResult.comment + " " + orderResult.price);
      
      Sleep(1000);
      
      MqlTradeRequest SLTPrequest;
      MqlTradeResult SLTPresult;
      ZeroMemory(SLTPrequest);
      ZeroMemory(SLTPresult);
      
      SLTPrequest.action = TRADE_ACTION_SLTP;
      SLTPrequest.symbol = Symbol();
      SLTPrequest.sl = sl;
      SLTPrequest.tp = tp;
      
      OrderSend(SLTPrequest, SLTPresult);
      Print("Open Order: " + SLTPresult.retcode + " -> " + SLTPresult.comment);
}

string MGHelper::orderToString(MqlTradeRequest &request){
   string output = "Action: " + request.action + 
   " Comment: " + request.comment + 
   " Deviation: " + request.deviation + 
   " Expiration: " + request.expiration + 
   " Magic: " + request.magic + 
   " Order: " + request.order + 
   " Price: " + request.price + 
   " SL: " + request.sl + 
   " Stoplimit: " + request.stoplimit + 
   " Symbol: " + request.symbol + 
   " TP: " + request.tp + 
   " Type: " + request.type + " (" + ORDER_TYPE_BUY + " " + ORDER_TYPE_SELL + ") " + 
   " FillingType: " + request.type_filling + " (" + ORDER_FILLING_FOK + ")" +
   " TypeTime: " + request.type_time + 
   " Volume: " + request.volume;
   
   return output;
}