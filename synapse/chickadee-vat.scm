(define-module (synapse chickadee-vat)
  #:use-module (chickadee)
  #:use-module (chickadee scripting)
  #:use-module (synapse concurrent-queue)
  #:use-module (goblins vat)
  #:use-module (ice-9 match)
  #:export (make-chickadee-vat))

(define* (make-chickadee-vat #:key (name 'chickadee)
                             (agenda (current-agenda)))
  (define vat-script #f)
  (define message-queue (make-concurrent-queue))
  (define (start churn)
    (define (handle-messages)
      (if (concurrent-queue-empty? message-queue)
          (begin
            (sleep (current-timestep)))
          (match (concurrent-dequeue! message-queue)
            ((msg return-channel)
             (channel-put return-channel (churn msg)))
            (msg
             (churn msg))))
      (handle-messages))
    (with-agenda agenda
      (set! vat-script (script (handle-messages)))))
  (define (halt)
    (cancel-script vat-script))
  (define (send msg return?)
    (if return?
        (let ((return-channel (make-channel)))
          (concurrent-enqueue! message-queue (list msg return-channel))
          (channel-get return-channel))
        (begin
          (concurrent-enqueue! message-queue msg))))
  (make-vat #:name name
            #:start start
            #:halt halt
            #:send send))
