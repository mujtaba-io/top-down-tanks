1. make sure only the effector node sends rpc.
currently all send rpc and it is causing many issues
like:
	1. all respawn at same time
	2. all get 100% health if even 1 player respawns
	
	...
	
	thisis because script gets called at all nodes
	so "make sure to call on one node on all devices"
