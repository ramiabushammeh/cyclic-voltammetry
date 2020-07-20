/* 
 * File:  waveform.c 
 * Author: 
 * Comments:
 * Revision history: 
 */

#include "xc.h"
#include "waveform.h"
#include "mcc_generated_files/mcc.h"
// input voltage to the CV apparatus 
#include "mcc_generated_files/dac1.h"
// reference voltage to the CV apparatus
#include "mcc_generated_files/dac2.h"
#include "mcc_generated_files/tmr1.h"
#include "mcc_generated_files/adc1.h"
#include "mcc_generated_files/uart2.h"

typedef struct _WAVEFORM_OBJ_STRUCT
{
    // reference source voltage for the DAC
    uint16_t refSourceVoltmV;
    // reference voltage for the CV
    uint16_t refVoltmV;
    uint8_t refVoltVal;

    
    uint8_t maxVal;
    uint8_t minVal;
    
    // time in s x 10^-2 until the DAC needs to be inc or dec to meet scan rate
    uint16_t updateDelayTime;  
    
    // Waveform state machine tracker
    // 0 - Standby
    // 1 - Scanning up
    // 2 - Scanning down
    uint8_t stateTracker;
    
    uint8_t currentVOutVal;

} WAVEFORM_OBJ;

static WAVEFORM_OBJ waveform_obj;

void initWaveform (void)
{
    // DAC reference supply voltage of 5V
    waveform_obj.refSourceVoltmV = 5000;
    // CV reference of 2.5V
    waveform_obj.refVoltmV = 2500; 
    waveform_obj.refVoltVal = ((uint32_t)256 * waveform_obj.refVoltmV ) / waveform_obj.refSourceVoltmV;
    
    setMaxVolt( 1000 );
    setMinVolt( 1000 );
    setScanRate ( 10000 );
    
    waveform_obj.stateTracker = 0;
    waveform_obj.currentVOutVal = waveform_obj.refVoltVal;
    
    // set the output DAC voltages
    setReference(waveform_obj.refVoltVal);
    setOutVolt(waveform_obj.currentVOutVal);
}

void setScanRate (uint16_t scanRate)
{
    // input scan rate should have units of v * 10^-4 / s
    // update time in s x 10^-2 = ( DAC supply voltage [mV] * 10 / 256 ) * ( 1 / scan rate [V * 10^-4] ) * (100)
    waveform_obj.updateDelayTime =  ((uint32_t)waveform_obj.refSourceVoltmV * 1000) / 256 / scanRate;
    TMR1_SetTickerFactor(waveform_obj.updateDelayTime);
}

void setMaxVolt (uint16_t voltmV)
{
    // clip the voltage is within range
    if (voltmV > waveform_obj.refVoltmV)
    {
        voltmV = waveform_obj.refVoltmV;
    }
    
    waveform_obj.maxVal = ( 256 * (uint32_t)voltmV ) / waveform_obj.refSourceVoltmV + waveform_obj.refVoltVal;
}

void setMinVolt (uint16_t voltmV)
{
    // clip the voltage is within range
    if (voltmV > waveform_obj.refVoltmV)
    {
        voltmV = waveform_obj.refVoltmV;
    }
    
    waveform_obj.minVal = waveform_obj.refVoltVal - ( 256 * (uint32_t)voltmV ) / waveform_obj.refSourceVoltmV;
}

void setOutVolt ( uint8_t volt )
{
    DAC1_OutputSet(volt);
}

void setReference ( uint8_t volt )
{
    DAC2_OutputSet(volt);
}

void startWaveform (void)
{
    waveform_obj.currentVOutVal = waveform_obj.refVoltVal;
    
    // set the output DAC voltage
    setReference(waveform_obj.refVoltVal);
    setOutVolt(waveform_obj.currentVOutVal);
    
    // set the state machine
    waveform_obj.stateTracker = 1;
    
}

void stopWaveform (void)
{
    // set the state machine
    waveform_obj.stateTracker = 0;
    
    waveform_obj.currentVOutVal = waveform_obj.refVoltVal;
    
    // set the output DAC voltage
    setReference(waveform_obj.refVoltVal);
    setOutVolt(waveform_obj.currentVOutVal);
}

void pauseWaveform (void)
{
    static uint8_t prevState = 0;
    
    if (waveform_obj.stateTracker == 0)
    {
        waveform_obj.stateTracker = prevState;
    }
    else
    {
        prevState = waveform_obj.stateTracker;
        waveform_obj.stateTracker = 0;
    }
    
}

uint8_t getWaveformStatus (void)
{
    return waveform_obj.stateTracker;
}

void handleWaveform ()
{
    // if this has been called, i means that the update time has passed
    
    // Rising scan
    if (waveform_obj.stateTracker == 1)
    {
        // send the output voltage
        sendVOutVal();
        
        // sample the output of the CV
        sampleOutput();
        
        setOutVolt(++waveform_obj.currentVOutVal);
        
        // if the output value is greater or equal then the max voltage the switch to falling scan
        if (waveform_obj.currentVOutVal >= waveform_obj.maxVal)
        {
            waveform_obj.stateTracker = 2;
        }
    }
    // Falling Scan
    else if (waveform_obj.stateTracker == 2)
    {
        // send the output voltage
        sendVOutVal();
        
        // sample the output of the CV
        sampleOutput();
        
        setOutVolt(--waveform_obj.currentVOutVal);
        
        // if the output value is greater or equal then the max voltage the switch to falling scan
        if (waveform_obj.currentVOutVal <= waveform_obj.minVal)
        {
            waveform_obj.stateTracker = 1;
        }
    }
}

void sampleOutput(void)
{
    ADC1_ChannelSelect(ADC1_OUTPUT_CV);
    
    uint8_t sampleCount;
    uint8_t samplesAveraged = 50;
    uint32_t result = 0;
    
    for (sampleCount = 0; sampleCount < samplesAveraged; sampleCount++)
    {
        ADC1_Start();
        //Provide Delay
        uint16_t delayCount;
        for(delayCount=0;delayCount<1000;delayCount++)
        {
        }
        ADC1_Stop();

        while(!ADC1_IsConversionComplete())
        {
            ADC1_Tasks();   
        }

        result = result + ADC1_ConversionResultGet();
    }
    
    result = result / samplesAveraged;
    
    // write identifier
    UART2_Write('i');
    // write lower byte
    UART2_Write(0x00FF & result);
    // write upper byte
    UART2_Write(0x00FF & (result >> 8));
}

void sendVOutVal (void)
{    
    // write identifier
    UART2_Write('v');
    // write lower byte
    UART2_Write(0x00FF & waveform_obj.currentVOutVal);
    // write upper byte
    UART2_Write(0x00FF & (waveform_obj.currentVOutVal >> 8));
}