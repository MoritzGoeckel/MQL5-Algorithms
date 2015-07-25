#property copyright "Copyright 2015, Moritz Göckel"
#property link      "https://www.moritzgoeckel.com"
#property version   "1.00"

int OnInit()
{
   EventSetTimer(60);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   
}

void OnTick()
{
   
}

void OnTimer()
{
   
}
