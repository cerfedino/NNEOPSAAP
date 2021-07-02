;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname media) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require racket/base)
(require 2htdp/image
         (only-in racket/gui/base play-sound)
         (only-in racket/gui/base get-display-size))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: 
;     find-min :  List<Number> -> Number
;         returns a random  upgrade name based on probability
; Header/Stub 
;     (define (find-min xs) -20)

;Step 4 . Template
;(define (find-min xs)
;  (cond
;    [(cons? xs) (if (cons? (rest xs))
;                    (min (first xs) (find-min ...))
;                    ...)]))

;Step 5 . Code 
(define (find-min xs)
  (cond
    [(cons? xs) (if (cons? (rest xs))
                    (min (first xs) (find-min (rest xs)))
                    (first xs))]))

; BLANK-CANVAS : Image
(define BLANK-CANVAS (local
                       ((define size (find-min (call-with-values (lambda () (get-display-size)) list))))
                       (if (> size 1999)
                            (square 1999 "solid" "black")
                            (square size "solid" "black"))))

; screenScale : Number
;   interpretation: a ratio based on the screen size. This scale is used in speed, positioning and scaling. This way the game looks and behaves the same way on any monitor size
(define screenScale
    (/ (image-width BLANK-CANVAS) 1800 ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IMAGE DEFINITIONS
(define SPACESHIP1-IMG (scale (* 0.3 screenScale) (bitmap "img/spaceship1.png")))
(define LASERBEAM-IMG (scale (* 4 screenScale) (bitmap "img/laser-beam.png")))

(define HEART-IMG (scale (* 2.4 screenScale) (bitmap "img/heart.png")))

(define UPG_LIFE-IMG HEART-IMG)
(define UPG_SPEEDMUL-IMG (scale (* 1 screenScale) (bitmap "img/upg/upg-speedMul.png")))
(define UPG_FRONT-IMG (scale (* 1 screenScale) (bitmap "img/upg/upg-front.png")))
(define UPG_DIAGONAL-IMG (scale (* 1 screenScale) (bitmap "img/upg/upg-diagonal.png")))

(define ASTEROID1-IMG (scale (* 0.8 screenScale) (bitmap "img/asteroid1.png")))
(define ASTEROID2-IMG (scale (* 0.8 screenScale) (bitmap "img/asteroid2.png")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SFX DEFINITIONS
(define (LASERBEAM_SFX) (play-sound "resources/audio/laserblaster.wav" #true))
(define (ASTEROID_HIT_SFX) (play-sound "resources/audio/asteroid-hit.wav" #true))
(define (PLAYER_HIT_SFX) (play-sound "resources/audio/player-hit.wav" #true))
(define (PLAYER_HEAL_SFX) (play-sound "resources/audio/player-heal.wav" #true))
(define (PLAYER_UPGRADE_SFX) (play-sound "resources/audio/player-upgrade.wav" #true))
(define (CLICK_SFX) (play-sound "resources/audio/click.wav" #true))
(define (PLAY_SFX) (play-sound "resources/audio/Play.wav" #true))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide (all-defined-out))


