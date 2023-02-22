(use-modules (goblins))
(use-modules (fibers timers))
(use-modules (goblins actor-lib cell))
(use-modules (goblins actor-lib methods))
(use-modules (ice-9 optargs))

(define (^neuron bcom name threshold value connections)
	(methods
		((get)
			(format #f "[~a] ~a / ~a" name value threshold))
		((list)
			(format #f "[~a] connections: ~a" name connections))
		((connect neuron)
			(bcom (^neuron bcom name threshold value (cons neuron connections))))
		((delayed delay)
			(begin
				(sleep delay)
				(format #f "[~a] delayed reaction" name)))
		((receive input)
			(define new-value (+ value input))
			(if (> new-value threshold)
				(begin
					(map (lambda (n) ($ n 'receive 1)) connections)
					(bcom (^neuron bcom name threshold 0 connections)
						(format #f "[~a] Fired!" name)))
				(bcom (^neuron bcom name threshold new-value connections)
					(format #f "[~a] increment to ~a" name new-value))))))




;;
