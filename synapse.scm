(use-modules (goblins))
(use-modules (goblins actor-lib cell))
(use-modules (goblins actor-lib methods))

(define (^neuron bcom name threshold value)
	(methods
		((get)
			(format #f "[~a] ~a / ~a" name value threshold))
		((receive input)
			(define new-value (+ value input))
			(if (> new-value threshold)
				(bcom (^neuron bcom name threshold 0)
					(format #f "[~a] Fired!" name))
				(bcom (^neuron bcom name threshold new-value)
					(format #f "[~a] increment to ~a" name new-value))))))


