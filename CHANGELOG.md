* 0.9.8 
	- reverting to 0.9.6 and using the Claude.ai installer
	- restored event model
	- found better dev/prod flow. Switching between dev and prod builds was causing a 
	  lot of small errors because of the number of manual changes required for switching
	  context. this is resolved by setting the base dir in the Export.lua area now.
	- restored si_config.lua written by the controller, ensure that all internal paths
	  write with trailing slashes convention. 

* 0.9.7
    - tried to completely rewrite the installer with Claude.ai
    - however this version breaks the event model, making the Hornet unusable

* 0.9.6
	- try to fix installer so that lfs global not assumed
	- add more logging to realweather api
	- make sure files match


* 0.9.5
	- refactoring: move to Mods/Services instead of putting everything in Scripts
	- support all aircraft, helis and maps by default
	- add ident for supported aircraft
	- refactor to make it easier to add supported aircraft implementations
	- added plane touchdown metrics (SI can react to hard landings or advise on next taxiway)


* 0.9.0 
	- initial release

