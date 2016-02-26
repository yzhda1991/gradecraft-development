EventLogger.configure do |config|
  config.backoff_strategy = [
    0, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 420, 540, 660, 780,
    900, 1_140, 1_380, 1_520, 1_760, 3_600, 7_200, 14_400, 28_800
  ]
end
