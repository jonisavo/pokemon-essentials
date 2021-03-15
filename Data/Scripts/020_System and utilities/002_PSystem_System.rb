def pbChooseLanguage
  commands=[]
  for lang in Settings::LANGUAGES
    commands.push(lang[0])
  end
  return pbShowCommands(nil,commands)
end

def pbScreenCapture
  t = pbGetTimeNow
  filestart = t.strftime("[%Y-%m-%d] %H_%M_%S.%L")
#  capturefile = RTP.getSaveFileName(sprintf("%s.png", filestart))
#  Graphics.snap_to_bitmap.save_to_png(capturefile)
  capturefile = RTP.getSaveFileName(sprintf("%s.bmp", filestart))
  Graphics.screenshot(capturefile)
  pbSEPlay("Pkmn exp full") if FileTest.audio_exist?("Audio/SE/Pkmn exp full")
end

def pbDebugF7
  if $DEBUG
    Console::setup_console
    begin
      debugBitmaps
    rescue
    end
    pbSEPlay("Pkmn exp full") if FileTest.audio_exist?("Audio/SE/Pkmn exp full")
  end
end



module Input
  unless defined?(update_KGC_ScreenCapture)
    class << Input
      alias update_KGC_ScreenCapture update
    end
  end

  def self.update
    update_KGC_ScreenCapture
    if trigger?(Input::F8)
      pbScreenCapture
    end
    if trigger?(Input::F7)
      pbDebugF7
    end
  end
end
