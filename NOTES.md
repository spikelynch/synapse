# Scheme notes

## Modules

something like

(use-modules (synapse thing))

will try to load

./synapes/thing.scm

somewhere in the load path - you have to explicitly add the pwd to the load
path

## Sunday 19th

I've hooked the chickadee-vat code in but when I try to spawn something in 
the vat, I get an error "vat is not running"

- manually started the vat

- running things like spawn get "abort with unknown prompt"

I think this is because I need to send everything the chickadee vat does
in via the chickadee event loop