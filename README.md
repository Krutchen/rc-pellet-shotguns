# rc-pellet-shotguns
Making RC pellet shotguns for the SLMC, scripted by your coding father DREAD HUDSON

We are using PRIM_TEXT to transfer a base64 encoded series of integers in a strided list. We are using 3 base64s for XYZ which returns a uniform length.
As of right now, the maximum number of shots we can transfer is 23, which is honestly overkill, but it's better to have more than enough room than riding the storage space to the line.
Shotgun trails are just "your number of pellets"- cluster rezzed raycast trails, all they do is decode the vector, rotate to look at the vector, and move towards it with a ribbon particle. This makes it so each pellet has its own trail and it telegraphs exactly what's happening with the shotgun, visibility was one of the major issues people had with the previous iteration of shotguns that used a sensor w/ detection tube and edge falloff.

Right now we don't have a concrete "how to balance" spreadsheet, look at the BASIC VALUES i provided for a pump action and use your head.
A Semi automatic combat shotgun should have less range and pellets, a sidearm should also not be out performing a big boy combat shotgun.
If you do an AT blast like the Chaos "Inferno Blast", reduce your pellets and max range as a trade for AT pellets.

Details about the EXAMPLE SCRIPTS
PUMP ACTION - .57 refire rate, 8 shots a little under 2 shots a second. This is a slowish firing pump action with moderate range, you can hammer the trigger but it grows in spread. 10 Pellets, 10 AT to LBA Light objects
This is the script currently in "[Heretech] Combat Shotgun v.1.1" and is a 1:1 with our Accatran pump shotgun.
