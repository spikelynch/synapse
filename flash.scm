
;; todo for today - try to get the chickadee-vat loading and "running"
;; in some sens


(use-modules 
	(chickadee)
 	(chickadee math vector)
 	(chickadee math rect)
 	(chickadee graphics sprite)
 	(chickadee graphics color)
 	(chickadee scripting)
  (goblins)
  (goblins actor-lib cell)
  (goblins actor-lib methods)
  (synapse chickadee-vat))



(define window-width 800)
(define window-height 600)

(define on-sprite #f)
(define off-sprite #f)

(define (^node bcom my-name)
  (lambda (value)
    (format #f "Ping ~a ~a" my-name value)))


(define (^neuron bcom name threshold value connections)
  (methods
    ((get)
      (format #f "[~a] ~a / ~a" name value threshold))
    ((list)
      (format #f "[~a] connections: ~a" name connections))
    ((connect neuron)
      (bcom (^neuron bcom name threshold value (cons neuron connections))))
    ((receive input)
      (define new-value (+ value input))
      (if (> new-value threshold)
        (begin
          (map (lambda (n) ($ n 'receive 1)) connections)
          (bcom (^neuron bcom name threshold 0 connections)
            (format #t "[~a] Fired!\n" name)))
        (bcom (^neuron bcom name threshold new-value connections)
          (format #t "[~a] increment to ~a\n" name new-value))))))



(define my-vat (make-chickadee-vat #:agenda (current-agenda)))

(vat-start! my-vat)


(define nodes '())


(define (reset!)
  (set! nodes '()))

(define* (create-node name pos threshold)
	(list
    (cons 'neuron (with-vat my-vat (spawn ^neuron name 10 0 '())))
    (cons 'name name)
		(cons 'pos pos)
		(cons 'threshold threshold)
		(cons 'value #f)))

(define (add-node! name pos threshold)
  (set! nodes
    (cons
     (create-node name pos threshold) nodes)))


(define (draw-node node)
  (draw-sprite
  	(if (assoc-ref node 'value) on-sprite off-sprite)
   	(assoc-ref node 'pos)))

(set! on-sprite (load-image "assets/on.png"))
(set! off-sprite (load-image "assets/off.png"))



(define clock-script
    (script
     (while #t
      (for-each (lambda (n)
        (begin
          (assoc-set! n 'value (not (assoc-ref n 'value)))
          (with-vat my-vat ($ (assoc-ref n 'neuron) 'receive 1))))
        nodes)
       (sleep 2))))


;; load isn't working for me with chickadee play
(define (load)
  (set! on-sprite (load-image "assets/on.png"))
  (set! off-sprite (load-image "assets/off.png"))
  (format #t "load was called!"))

(define (mouse-press button clicks x y)
  (script
    (format #t "[ ~a ~a ]\n" x y)
    (add-node! "Node" (vec2 x y) 10)))


(define (draw alpha)
  (for-each draw-node nodes))

(define (update dt)
  (let ((dt-seconds (/ dt 1000.0)))
    (update-agenda dt)))



; (define (start!)
;   (run-game
;    #:window-width window-width
;    #:window-height window-height
;    #:load load
;    #:update update
;    #:draw draw))

; (define (stop!)
;   (abort-game))

; (start!)
; (reset!)

;;(cancel-script spawn-asteroid-script)

