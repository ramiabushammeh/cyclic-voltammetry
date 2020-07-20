/**
  Generated Main Source File

  Company:
    Microchip Technology Inc.

  File Name:
    main.c

  Summary:
    This is the main file generated using MPLAB(c) Code Configurator

  Description:
    This header file provides implementations for driver APIs for all modules selected in the GUI.
    Generation Information :
        Product Revision  :  MPLAB(c) Code Configurator - 3.16
        Device            :  PIC24F16KM202
        Driver Version    :  2.00
    The generated drivers are tested against the following:
        Compiler          :  XC16 1.26
        MPLAB             :  MPLAB X 3.20
*/

/*
    (c) 2016 Microchip Technology Inc. and its subsidiaries. You may use this
    software and any derivatives exclusively with Microchip products.

    THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
    EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
    WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
    PARTICULAR PURPOSE, OR ITS INTERACTION WITH MICROCHIP PRODUCTS, COMBINATION
    WITH ANY OTHER PRODUCTS, OR USE IN ANY APPLICATION.

    IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
    INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
    WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
    BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
    FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
    ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
    THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.

    MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF THESE
    TERMS.
*/

#include "mcc_generated_files/mcc.h"
#include "waveform.h"

/*
                         Main application
 */

uint8_t RXData;
uint16_t RXData16;
uint8_t analogOut = 0;
uint16_t updatePeriodms = 1; 
uint16_t lastUpdateTime = 0; 
uint16_t currentTime = 0;

int main(void)
{
    // initialize the device
    SYSTEM_Initialize();

    TMR1_Start();
    
    initWaveform(); 
    
    FB_R1_CTRL_SetHigh();
    FB_R2_CTRL_SetLow();
    FB_R3_CTRL_SetLow();
    FB_R4_CTRL_SetLow();
       
    while (1)
    {
        // if there is data ready
        if (UART2_StatusGet() & UART2_RX_DATA_AVAILABLE)
        {
            // read the data
            RXData = UART2_Read();
            
            switch (RXData)
            {
                // turn LED on
                case 'a':
                {
                    UART2_Write('a');
                    LED_Out_SetHigh();
                    break;
                }
                
                // Turn LED off
                case 'b':
                {
                    LED_Out_SetLow();
                    break;
                }
                
                // Set the max voltage
                case 'c':
                {
                    RXData16 = RX16bit();                                      
                    
                    setMaxVolt(RXData16);
                    
                    break;
                }
                
                // Set the min voltage
                case 'd':
                {
                    RXData16 = RX16bit();                                       
                    
                    setMinVolt(RXData16);
                    
                    break;
                }
                
                // Set the scan rate
                case 'e':
                {
                    RXData16 = RX16bit();                                         
                    
                    setScanRate(RXData16);
                    
                    break;
                }
                
                // Start waveform
                case 'f':
                {
                    startWaveform();
                    
                    break;
                }
                
                // Stop waveform
                case 'g':
                {
                    stopWaveform();
                    
                    break;
                }
                
                // Pause waveform
                case 'h':
                {
                    pauseWaveform();
                    
                    break;
                }

                // Set Voltage
                case 'j':
                {
                    // if the waveform generation is in standby
                    if ( getWaveformStatus() == 0)
                    {
                        RXData = RX8bit();
                        setOutVolt(RXData);
                    }
                    
                    break;
                }
                
                // Send current
                case 'k':
                {
                    sampleOutput();
                    
                    break;
                }
                
                // Select the feedback resistor
                case 'l':
                {
                    RXData = RX8bit();
                    
                    switch(RXData)
                    {
                        case 1:
                        {
                            FB_R1_CTRL_SetHigh();
                            FB_R2_CTRL_SetLow();
                            FB_R3_CTRL_SetLow();
                            FB_R4_CTRL_SetLow();
                            break;
                        }
                                                
                        case 2:
                        {
                            FB_R1_CTRL_SetLow();
                            FB_R2_CTRL_SetHigh();
                            FB_R3_CTRL_SetLow();
                            FB_R4_CTRL_SetLow();
                            break;
                        }
                        
                        case 3:
                        {
                            FB_R1_CTRL_SetLow();
                            FB_R2_CTRL_SetLow();
                            FB_R3_CTRL_SetHigh();
                            FB_R4_CTRL_SetLow();
                            break;
                        }
                                                
                        case 4:
                        {
                            FB_R1_CTRL_SetLow();
                            FB_R2_CTRL_SetLow();
                            FB_R3_CTRL_SetLow();
                            FB_R4_CTRL_SetHigh();
                            break;
                        }
                    }
                    break;
                }
                
            }                
        }
                
    }

    return -1;
}
/**
 End of File
*/