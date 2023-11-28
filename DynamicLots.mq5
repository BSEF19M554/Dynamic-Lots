#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

//Inputs
input double percentRisk = 1.0;
input int SL = 100;
input int TP = 200;
bool isTradeOpen = false;
CTrade trade;
double lotCalc = 0.0;

void OnDeinit(const int reason){
   isTradeOpen = false;
   lotCalc = 0.0;
}

void OnTick()
{
   if(!isTradeOpen){
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double volumeStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      double sl = ask - SL * _Point;
      double tp = ask + TP * _Point;
      double SlForCalc = ask - sl;
      
      double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * percentRisk / 100;
      double moneyVolumeStep = (SlForCalc / tickSize) * tickValue * volumeStep;
      
      lotCalc = (riskMoney / moneyVolumeStep) * volumeStep;
      
      double min = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double max = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      if(lotCalc < min){
         Print("Lot set to minimum.");
         lotCalc = min;
      }
      else if(lotCalc > max){
         Print("Lot higher than maximum error.");
         lotCalc = 0.0;
      }
      
      lotCalc = NormalizeDouble(lotCalc, 2);
      Print(lotCalc);
      lotCalc = (int)MathFloor(lotCalc/step) * step;
      Print(lotCalc);
      
      trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, lotCalc, ask, sl, tp, "Trade taken");
   }
}