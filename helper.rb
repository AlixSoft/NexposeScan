#!/usr/bin/env ruby

def calc_scan_time t1, t2
  t1 = Time.parse(t1)
  t2 = Time.parse(t2)

  (t2 - t1) * 1000.0
end

def time_format t
  t = t / 1000
  mm, ss = t.divmod(60)
  hh, mm = mm.divmod(60)
  "%d:%d:%d" % [hh, mm, ss]
end

def correct_data? asset
  b1 = !asset["start"].empty? && !asset["end"].empty?
  b2 = asset.has_key?("scan_time") ? (asset["scan_time"] > 0) : true
  b1 && b2
end