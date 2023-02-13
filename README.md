# LM03_lightmeter

This repository contains Matlab code that can be used to drive the LM03 light meter, a Cambridge Research Systems demo product. 
The LM03 is a microcontroller with two photo sensors capable of recording up to 4000 samples at a frame rate 200,000 Hz. 
In the minimal script [LM03_minimal_test.m](../main/LM03_minimal_test.m) a single recording is performed. 

Here I used this script to measure the speed of a Gaussian blob presented by a Propixx DLP projector (VPixx technologies) running at 1440 Hz. Specifically, the task was to make sure that leftward and rightward motion was presented a the specified velocity. 
The two photodiodes were horizontally aligned around screen center with a distance of approximately 2 degrees of visual angle (see [setup.jpg](../main/setup.jpg)). During presentation, a white Gaussian blob on black background traveled across the two sensors with constant velocity. 
The duration between the responses of the two photodiodes would thus indicate the speed at which the stimulus traveled across the screen. 

Around 1400 trials were collected, and the analysis of the resulting data is shown in the markdown document [LM03_lightmeter_data_analysis.md](../main/LM03_lightmeter_data_analysis.md). 
Results are reported in the paper (in preparation) **"High-speed motion perception is constrained to the fastest movements of the human eye"** by Martin Rolfs, Richard Schweitzer, Eric Castet, Tamara L. Watson, and Sven Ohl. 
