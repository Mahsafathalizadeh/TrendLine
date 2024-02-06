//###<Experts/Advisors/TrendLineTamrin4.mq5>
//the strategy is about drawing upper and lower trendlines : to do so we use a staight line's equation => y=mx+c => m=(y-c)/x
//main logic = we calculate midbar and the depending on whether the high/low is at the left or right side of the midbar, we determine bull/bear trendline.
//to draw a line we need bar, price of bar, time and slope
#include <Object.mqh>
struct STrendPoint
{
    int bar;
    double price;
    datetime time;
};

struct STrenLine
{
    double slope;
    STrendPoint base;
};

class CTrendLineHiLo : public CObject
{
private:
    /* data */
protected:
    //variables needed for trendlines
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    STrenLine UpperTrendline;
    STrenLine LowerTrendline;
    int start;
    int length;
    double ValueAt(const int index, const STrenLine &trendline);

public:
    CTrendLineHiLo (const int Start, const int Length);
    ~CTrendLineHiLo ();

    void Update();
    void UpdateLower();
    void UpdateUpper();

    double UpperValueAt(const int index);
    double UpperValueAt(const datetime time);
    double LowerValueAt(const int index);
    double LowerValueAt(const datetime time);

    //we need functions to modify parameters(start & length) in CTrendHiLo
  
};

CTrendLineHiLo ::CTrendLineHiLo (const int Start, const int Length)
{
    symbol = Symbol();
    timeframe = (ENUM_TIMEFRAMES)Period();
    start = Start;
    length = Length;
}
CTrendLineHiLo ::~CTrendLineHiLo ()
{
}
void CTrendLineHiLo :: Update()
{
    UpdateLower();
    UpdateUpper();
}
void CTrendLineHiLo :: UpdateLower()
{
    //what we need to drae a lower trend line? first low, price of first low,comparing next bar, mid bar,best slope
    int firstBar = iLowest(symbol,timeframe,MODE_LOW,length,start);
    int nextBar = firstBar;
    double firstValue = 0;
    double bestslope = 0;
    int midbar = start + (length/2);

    if (firstBar >= midbar) // uptrend
    {
        while (nextBar>=midbar)
        {
            firstBar=nextBar;
            bestslope=0;
            firstValue = iLow(symbol,timeframe,firstBar);
            for (int i = firstBar-1; i >=start; i--)
            {
                int position = firstBar-i;
                double slope = (iLow(symbol,timeframe,i)-firstValue)/position;
                if (firstBar==nextBar || slope<bestslope)
                {
                    nextBar = i;
                    bestslope = slope;
                }  
            } 
        }
    }
    else //downtrend
    {
        while (nextBar < midbar)
        {
            firstBar=nextBar;
            bestslope=0;
            firstValue = iLow(symbol,timeframe,firstBar);
            for (int i = firstBar+1; i < (start+length); i++)
            {
                int position = i-firstBar;
                double slope = (firstValue - iLow(symbol,timeframe,i))/position;
                if (firstBar==nextBar || slope > bestslope)
                {
                    nextBar = i;
                    bestslope = slope;
                }
            }
        } 
    }
    LowerTrendline.slope = bestslope;
    LowerTrendline.base.bar = firstBar;
    LowerTrendline.base.price = firstValue;
    LowerTrendline.base.time = iTime(symbol,timeframe,firstBar);
}
void CTrendLineHiLo :: UpdateUpper()
{
    int firstBar = iHighest(symbol,timeframe,MODE_HIGH,length,start);
    int nextBar = firstBar;
    double firstValue = 0;
    double bestslope = 0;
    int midbar = start + ((length+1)/2);

    if (firstBar < midbar) //uptrend
    {
        while (nextBar < midbar)
        {
            firstBar=nextBar;
            bestslope=0;
            firstValue = iHigh(symbol,timeframe,firstBar);
            for (int i = firstBar+1; i < (start+length); i++)
            {
                int position = i-firstBar;
                double slope = (firstValue-iHigh(symbol,timeframe,i))/position;
                if (firstBar==nextBar || slope<bestslope)
                {
                    nextBar=i;
                    bestslope=slope;
                } 
            }           
        }
    }
    else //downtrend
    {
        while (nextBar>=midbar)
        {
            firstBar=nextBar;
            bestslope=0;
            firstValue = iHigh(symbol,timeframe,firstBar);
            for (int i = firstBar-1; i >= start; i--)
            {
                int position = firstBar-i;
                double slope = (iHigh(symbol,timeframe,i)-firstValue)/position;
                if (nextBar==firstBar || slope>bestslope)
                {
                    nextBar=i;
                    bestslope=slope;
                } 
            }     
        } 
    }
    UpperTrendline.slope = bestslope;
    UpperTrendline.base.bar=firstBar;
    UpperTrendline.base.price=firstValue;
    UpperTrendline.base.time=iTime(symbol,timeframe,nextBar);
}
double CTrendLineHiLo :: UpperValueAt(const int index)
{
    return(ValueAt(index,UpperTrendline));
}
double CTrendLineHiLo :: UpperValueAt(const datetime time)
{
    int index = iBarShift(symbol,timeframe,time,false);
    return(ValueAt(index,UpperTrendline));
}

double CTrendLineHiLo :: LowerValueAt(const int index)
{
    return(ValueAt(index,LowerTrendline));
}
double CTrendLineHiLo :: LowerValueAt(const datetime time)
{
    int index = iBarShift(symbol,timeframe,time,false);
    return(ValueAt(index,LowerTrendline));
}

double CTrendLineHiLo :: ValueAt(const int index, const STrenLine &trendline)
{
    int offset = trendline.base.bar - index;
    double value = trendline.base.price + (trendline.slope * offset) ;

    return(value);
}
