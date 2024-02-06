#include <TrendLineTamrin4.mqh>

//inputs
input int InpStart = 10;
input int InpLength = 60;


int OnInit()
{
    //first we create an object of the class
    CTrendLineHiLo *trend = new CTrendLineHiLo(InpStart,InpLength);
    trend.Update();

    PrintFormat("upper value at %i is %f",InpStart+InpLength,trend.UpperValueAt(InpStart+InpLength));
    PrintFormat("upper value at %i is %f",InpStart+InpLength,trend.LowerValueAt(InpStart+InpLength));
    
    //now we create trendline objects but first we delete the prev object
    ObjectDelete(0,"uppertrendline");
    ObjectDelete(0,"lowertrendline");

    //to create trendline we need x & y coordinates of first & second points
    ObjectCreate(0,"uppertrendline",OBJ_TREND,0,
    iTime(Symbol(),Period(),InpStart+InpLength),
    trend.UpperValueAt(InpStart+InpLength),
    iTime(Symbol(),Period(),0),
    trend.UpperValueAt(0));

    ObjectSetInteger(0,"uppertrend",OBJPROP_COLOR,clrDarkBlue);
    ObjectSetInteger(0,"uppertrend",OBJPROP_WIDTH,3);

    //to create trendline we need x & y coordinates of first & second points
    ObjectCreate(0,"lowertrendline",OBJ_TREND,0,
    iTime(Symbol(),Period(),InpStart+InpLength),
    trend.LowerValueAt(InpStart+InpLength),
    iTime(Symbol(),Period(),0),
    trend.LowerValueAt(0));

    ObjectSetInteger(0,"lowertrend",OBJPROP_COLOR,clrDarkBlue);
    ObjectSetInteger(0,"lowertrend",OBJPROP_WIDTH,3);

    delete trend;
    return(INIT_SUCCEEDED);



}
