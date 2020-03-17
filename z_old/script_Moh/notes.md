# Script and conversation for the experiment trial run at the SPINOZA fMRI workshop (November 2018)

## Author: Mohamed R.

Here are the scripts for the 3 experiments: https://www.dropbox.com/sh/2ubjt0zsgpns5ke/AADSvpB-mNtmnhOAh28eaICHa?dl=0
- Visual localizer
- Auditory Localizer
- Decoding

I edited the scripts to change the triggers from Trento functions to the normal functions.
Now the trigger is ’s’
You will see it in the code, and you can edit it according to the scanner there.

- Couple of notes :

In the motion decoding experiment :
- I added a static condition so you can do it in the same experiment if you want.
- I would suggest you remove the audio sound after every block saying ‘up , down , right , left’, because it will take a lot of time, and since you are piloting you shouldn’t waste time. It would be better if you get more runs and remove the audio voices for response collection.
- You can edit the directions by adding/removing directions from the script.

0 = right , 180= left , 90 = up , 270 = down , -1 = static

I think that should be it.
You remove all the commented code.

>ok, better to have a plan B in the case no possibility/time to run MVPA analysis. The design that I've discuss with Olivier may be more similar with Ceren's one but I might be wrong. In this design, we present all the 6 conditions in a series of 8 seconds (L_audio 1s; 05 iti; S_vision; .05 iti; etc).
Does it make sense to you? To me not too much, I'm sorry.


The static sounds I have are coming from the center of the sound bar.
Ceren has sounds from the right, left , up and down extreme.

>yes as trial, probably only 1 subj and few runs

If it is just a trial then no worries, just try.

>>The worry I have that I should tell you, we couldn’t decode Right vs Left in vision or Audition. Or when we could it was extremely weak. So its up to you to try an easier trial (R/L vs U/D) in Amsterdam or to try the harder one (R vs L).

>the point to try this in AMS is because of the 7t, maybe with high res it could work better the R vs L

Be careful when raising this point (I am saying this for you.) , don’t assume that higher resolution definitely means higher decoding.
For example (Zimmerman , 2011) Show axis of motion organisation at 7T, and they didn’t speak about individual directions, only axes.

>Thank you very much, I tried to run it but it enters the while loop at line 231 and it stays there. I guess it is waiting for a kbwait but I want to ask u before

It is waiting for the trigger . So press ’s’ on your keyboard as if it is the trigger. 4 times then the code will run.
