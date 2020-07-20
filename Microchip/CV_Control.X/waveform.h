/* 
 * File:  waveform.h 
 * Author: 
 * Comments:
 * Revision history: 
 */

// This is a guard condition so that contents of this file are not included
// more than once.  
#ifndef WAVEFORM_H
#define	WAVEFORM_H

#include <xc.h> // include processor files - each processor file is guarded. 
#include <stdint.h>

// TODO Insert appropriate #include <>

// TODO Insert C++ class definitions if appropriate

// TODO Insert declarations

// Comment a function and leverage automatic documentation with slash star star
/**
    <p><b>Function prototype:</b></p>
  
    <p><b>Summary:</b></p>

    <p><b>Description:</b></p>

    <p><b>Precondition:</b></p>

    <p><b>Parameters:</b></p>

    <p><b>Returns:</b></p>

    <p><b>Example:</b></p>
    <code>
 
    </code>

    <p><b>Remarks:</b></p>
 */

void initWaveform (void);

void setScanRate (uint16_t scanRate);

void setMaxVolt (uint16_t voltmV);

void setMinVolt (uint16_t voltmV);

void startWaveform ();

void stopWaveform ();

void pauseWaveform ();

void handleWaveform ();

void setOutVolt (uint8_t volt);

void setReference (uint8_t volt);

void sampleOutput(void);

void sendVOutVal (void);

uint8_t getWaveformStatus (void);

#ifdef	__cplusplus
extern "C"
{
#endif /* __cplusplus */

// TODO If C++ is being used, regular C code needs function names to have C 
// linkage so the functions can be used by the c code. 

#ifdef	__cplusplus
}
#endif /* __cplusplus */

#endif	/* WAVEFORM_H */

