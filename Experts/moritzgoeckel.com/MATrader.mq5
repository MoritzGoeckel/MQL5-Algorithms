#property copyright "Copyright 2015, Moritz Göckel"
#property link      "https://www.moritzgoeckel.com"
#property version   "1.00"

#include <trade/trade.mqh>
#include <moritzgoeckel.com/MGHelper.mqh>

MGHelper helper;

int OnInit()
{
   EventSetTimer(60);
   helper = new MGHelper();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
}

void OnTick()
{
   double slowMA[];
   helper.getMA(PERIOD_M1, 20, 100, slowMA);
   
   double fastMA[];
   helper.getMA(PERIOD_M1, 10, 100, fastMA);
   
   int trendforminutes = 2;
   
   bool buy = true;
   int i = 0;
   while (i < trendforminutes)
   {
      if(fastMA[i] <= slowMA[i])
      {
         buy = false;
         break;
      }
      i++;
   }
      
   bool sell = true;
   i = 0;
   while (i < trendforminutes)
   {
      if(fastMA[i] >= slowMA[i])
      {
         sell = false;
         break;
      }
      i++;
   }
   
   double ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK); //Kaufpreis
   double bid=SymbolInfoDouble(Symbol(),SYMBOL_BID); //Verkaufspreis
   double spread=ask-bid;
      
   double prices[];
   ArraySetAsSeries(prices,true);
   int copied = CopyClose(Symbol(), PERIOD_M1, 0, 60, prices);
   double min = prices[ArrayMinimum(prices)];
   double max = prices[ArrayMaximum(prices)];   
   
   bool positionIsOpen = PositionsTotal() != 0; 
   ENUM_POSITION_TYPE posType;
   
   if(positionIsOpen)
   {
      PositionSelect(Symbol());
      posType = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
   }
   else
      Print("No Open Position");
   
   if(buy && (posType != POSITION_TYPE_BUY || positionIsOpen == false))
   {
      Print("Buy");
      if(positionIsOpen)
         helper.closePositions();
      
      double distance = ask - min;
      
      helper.trade(true, ask - distance * 1.3, ask + distance * 2);
   }
   
   if(sell && (posType != POSITION_TYPE_SELL || positionIsOpen == false))
   {
      if(positionIsOpen)
         helper.closePositions();
      
      double distance = max - bid;
      
      Print("Sell");
      helper.trade(false, bid + distance * 1.3, bid - distance * 2);
   }
}

void OnTimer()
{
   
}
