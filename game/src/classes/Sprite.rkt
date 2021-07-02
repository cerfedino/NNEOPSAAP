;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Sprite) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;Libraries
(require racket/class)
(require racket/base)
(require "../resources/media.rkt")
(require 2htdp/image)


(define sprite% (class object%

                  ;; FIELDS

                  ; Input parameters to give on creation of a %sprite object
                  (init an-Image a-Posn a-SpeedStruct)
                  (super-new)

                  ; Multiplies the speed by the screenScale. This way the speed will always be scaled by the size of the monitor.
                  (field (speed (make-posn (* (posn-x a-SpeedStruct) screenScale) (* (posn-y a-SpeedStruct) screenScale))))
                  
                  ; Rotates the image based on the x and y speed, to make the sprite always faces the direction he's going. (e.g diagonal bullets)
                  (field (image  (rotate (if (= (posn-x speed) 0)
                                            0
                                            (- 270 (*(atan (/ (posn-y speed)(posn-x speed))) (/ 180 pi) ))) an-Image) ))
                  
                  ; The position of the sprite
                  (field (position a-Posn))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: 
;     apply-speed :  -> (void)
;         increments the %sprite 's position based on the speed
; Header/Stub 
;     (define/public (apply-speed) (void))

;Step 4 . Template
;(define/public (apply-speed)
;  (set! position (make-posn (+ ... (posn-x speed)) (+ ... (posn-y speed))))) ))

;Step 5 . Code 
                  (define/public (apply-speed)
                    (set! position (make-posn (+ (posn-x position)(posn-x speed)) (+ (posn-y position)(posn-y speed))))) ))
;;;;;;;;;;;;;;;;;;;;;;;                  
                  

(provide (all-defined-out))