# Synapse

Synapse is a control environment for generative music based on nodes which
play notes and send one another signals.

Each node has a threshold at which it fires - firing plays the node's note
and sends messages to the other nodes it's connected to which raise or lower
those node's values.

The nodes are done with Spritely Goblins and the gui is Chickadee

Sounds are played with SuperCollider

Writing it in the present tense makes it sound like it's already done!

TODO, in order:


Part 1:

a goblins node which can do:

- have a value and a threshold and a list of other nodes it connects to
- check to see if its value > threshold, fire if it is
- recieve a signal from another node
- do things when it fires:
  - write something to the command line
  - send signals to its downstream nodes


node methods:

- tick: event loop trigger, check v > t
- fire - called by the event loop
- connect - add a downstream node
- recieve - recieve a signal from upstream

There has to be a node called Clock which fires on a regular basis with no 
input