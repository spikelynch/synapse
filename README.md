# Synapse

Synapse is a control environment for generative music based on nodes which
play notes and send one another signals.

Each node has a threshold at which it fires - firing plays the node's note
and sends messages to the other nodes it's connected to which raise or lower
those node's values.

The nodes are done with Spritely Goblins and the gui is Chickadee

Sounds are played with SuperCollider

Writing it in the present tense makes it sound like it's already done!

TODO

- basic node that goes ping

- connect one node to another

- GUI to create nodes and connect them in chickadee


object model

- node 