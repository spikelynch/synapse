(define-module (synapse concurrent-queue)
  #:use-module (ice-9 format)
  #:use-module (ice-9 threads)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-9 gnu)
  #:use-module (chickadee data array-list)
  #:export (make-concurrent-queue
            concurrent-queue?
            concurrent-queue-length
            concurrent-queue-empty?
            concurrent-enqueue!
            concurrent-dequeue!
            concurrent-queue-clear!
            concurrent-queue-close!))

(define-record-type <concurrent-queue>
  (%make-concurrent-queue input output mutex condvar)
  concurrent-queue?
  (input concurrent-queue-input)
  (output concurrent-queue-output)
  (mutex concurrent-queue-mutex)
  (condvar concurrent-queue-condvar)
  (closed? concurrent-queue-closed? set-concurrent-queue-closed!))

(define (display-concurrent-queue q port)
  (format port "#<concurrent-queue length: ~d>" (concurrent-queue-length q)))

(set-record-type-printer! <concurrent-queue> display-concurrent-queue)

(define (make-concurrent-queue)
  "Return a new, empty queue."
  (%make-concurrent-queue (make-array-list) (make-array-list)
                          (make-mutex) (make-condition-variable)))

(define (concurrent-queue-length q)
  "Return the number of elements in Q."
  (+ (array-list-size (concurrent-queue-input q))
     (array-list-size (concurrent-queue-output q))))

(define (concurrent-queue-empty? q)
  "Return #t if Q is empty."
  (zero? (concurrent-queue-length q)))

(define (concurrent-enqueue! q item)
  "Add ITEM to Q."
  (if (concurrent-queue-closed? q)
      (error "queue is closed" q)
      (begin
        (with-mutex (concurrent-queue-mutex q)
          (array-list-push! (concurrent-queue-input q) item))
        (signal-condition-variable (concurrent-queue-condvar q)))))

(define (concurrent-dequeue! q)
  "Remove the first element of Q."
  (if (and (concurrent-queue-empty? q)
           (concurrent-queue-closed? q))
      #f
      (with-mutex (concurrent-queue-mutex q)
        ;; If the queue is empty, block until there's something to
        ;; dequeue.
        (when (concurrent-queue-empty? q)
          (wait-condition-variable (concurrent-queue-condvar q)
                                   (concurrent-queue-mutex q)))
        (if (concurrent-queue-empty? q)
            #f
            (let ((input (concurrent-queue-input q))
                  (output (concurrent-queue-output q)))
              (when (array-list-empty? output)
                (let loop ()
                  (unless (array-list-empty? input)
                    (array-list-push! output (array-list-pop! input))
                    (loop))))
              (array-list-pop! output))))))

(define (concurrent-queue-clear! q)
  "Remove all items from Q."
  (with-mutex (concurrent-queue-mutex q)
    (array-list-clear! (concurrent-queue-input q))
    (array-list-clear! (concurrent-queue-output q))))

(define (concurrent-queue-close! q)
  "Close Q so that no more items may be enqueued."
  (with-mutex (concurrent-queue-mutex q)
    (set-concurrent-queue-closed! q #t)
    (when (concurrent-queue-empty? q)
      (signal-condition-variable (concurrent-queue-condvar q)))))
