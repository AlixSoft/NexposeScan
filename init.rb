#!/usr/bin/env ruby

require 'yajl'
require 'time'
require_relative "helper"

start_time = Time.now
json = File.new('scan-times.json', 'r')
parser = Yajl::Parser.new
scan = parser.parse(json)


fast_time_asset = 0
fastest_asset = nil
long_time_asset = 0
longest_asset = nil
average_time = 0
sum_time = 0
assets_count = 0
assets_without_correct_data_count = 0

scan.each do |asset|
  if correct_data?(asset)
    scan_time = calc_scan_time(asset["start"], asset["end"])
    sum_time += scan_time

    asset["scan_time"] = scan_time

    if scan_time > 0
      assets_count += 1
      if scan_time > long_time_asset
        long_time_asset = scan_time
        longest_asset = asset
      end

      if fast_time_asset == 0
        fast_time_asset = scan_time
      elsif scan_time < fast_time_asset
        fast_time_asset = scan_time
        fastest_asset = asset
      end
    else
      assets_without_correct_data_count += 1
    end
  else
    assets_without_correct_data_count += 1
  end
end

average_time = sum_time / assets_count

fastest_average_time = 0
longest_average_time = 0
fastest_average_time_sum = 0
longest_average_time_sum = 0
fastest_average_assets_count = 0
longest_average_assets_count = 0


scan.each do |asset|
  if correct_data?(asset)
    if asset["scan_time"] <= average_time
      fastest_average_assets_count += 1
      fastest_average_time_sum += asset["scan_time"]
    else
      longest_average_assets_count += 1
      longest_average_time_sum += asset["scan_time"]
    end
  end
end

fastest_average_time = fastest_average_time_sum / fastest_average_assets_count
longest_average_time = longest_average_time_sum / longest_average_assets_count

fastest_average_assets = []
longest_average_assets = []

scan.each do |asset|
  if correct_data?(asset)
    fastest_average_assets << asset if fastest_average_time == asset["scan_time"]
    longest_average_assets << asset if longest_average_time == asset["scan_time"]
  end
end


finish_time = Time.now
script_time = (finish_time - start_time) * 1000.0

p "=== result ==="
p "1. Average scan time #{time_format(average_time)} (#{average_time} ms)"
p "2. Asset with the fastest scan (time #{time_format(fast_time_asset)} (#{fast_time_asset} ms))"
p "         #{fastest_asset}"
p "3. Asset with the longest scan (time #{time_format(long_time_asset)} (#{long_time_asset} ms))"
p "         #{longest_asset}"
p "4. Fastest average scan time #{time_format(fastest_average_time)} (#{fastest_average_time} ms)"
if fastest_average_assets.size == 0
  p "         No assets with the fastest average time"
else
  fastest_average_assets.each do |asset|
    p "         #{asset}"
  end
end
p "5. Longest average scan time #{time_format(longest_average_time)} (#{longest_average_time} ms)"
if longest_average_assets.size == 0
  p "         No assets with the longest average time"
else
  longest_average_assets.each do |asset|
    p "         #{asset}"
  end
end
p "6. Script time #{time_format(script_time)} (#{script_time} ms)"
p "Number of assets with wrong data #{assets_without_correct_data_count}"
p "=== !result ==="
