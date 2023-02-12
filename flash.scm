;; put a node in the middle of the window and make it flash on and off

(use-modules 
	(chickadee)
 	(chickadee math vector)
 	(chickadee math rect)
 	(chickadee graphics sprite)
 	(chickadee graphics color)
 	(chickadee scripting))



(define window-width 800)
(define window-height 600)

(define on-sprite #f)
(define off-sprite #f)
;;(define clock-script #f)

(define nodes '())


(define (reset!)
  (set! nodes '()))

(define* (create-node pos threshold)
	(list
		(cons 'pos pos)
		(cons 'threshold threshold)
		(cons 'value #f)))

(define (add-node! pos threshold)
  (set! nodes
    (cons
     (create-node pos threshold) nodes)))


(define (draw-node node)
  (draw-sprite
  	(if (assoc-ref node 'value) on-sprite off-sprite)
   	(assoc-ref node 'pos)))

(set! on-sprite (load-image "assets/on.png"))
(set! off-sprite (load-image "assets/off.png"))

(add-node! (vec2 100.0 100.0) 10)

(define clock-script
    (script
     (while #t
      (for-each (lambda (n) (assoc-set! n 'value (not (assoc-ref n 'value)))) nodes)
       (sleep 2))))


;; load isn't working for me with chickadee play?
(define (load)
  (set! on-sprite (load-image "assets/on.png"))
  (set! off-sprite (load-image "assets/off.png"))
  (add-node! (vec2 400.0 300.0) 10))


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

