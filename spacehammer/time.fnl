(fn date
  []
  (let [now (os.time)
        date (os.date "%Y%m%d" now)]
    (hs.eventtap.keyStrokes date)))

(fn datetime
  []
  (let [now (os.time)
        date (os.date "%Y%m%dT%H%M" now)]
    (hs.eventtap.keyStrokes date)))

(fn work-email
  []
  (let [now (os.time)
        date (os.date "%Y%m%dT%H%M" now)]
    (hs.eventtap.keyStrokes (.. "jay" "." "zawrotny" "+" "test" "-" date "@" "crunchydata.com"))))

{: date
 : datetime
 : work-email}
