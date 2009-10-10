class MLBAPI::Pitch < MLBAPI::Model

  attr_accessor :at_bat

  hash_attr_accessor :id, :type, :x, :y, :des, :sv_id, :start_speed, :end_speed, :sz_top, :sz_bot,
                     :pfx_x, :pfx_z, :px, :pz, :x0, :y0, :z0, :vx0, :vy0, :vz0, :ax, :ay, :az, :break_y,
                     :break_angle, :break_length, :pitch_type, :type_confidence, :spin_dir, :spin_rate

 # type="B" id="251" x="176.82" y="120.88" des="Ball" sv_id="091009_192609" start_speed="79.1" 
 # end_speed="72.6" sz_top="3.440" sz_bot="1.720" pfx_x="2.974" pfx_z="-6.286" px="-2.252" pz="3.584"
 # x0="-2.433" y0="50.000" z0="6.229" vx0="-0.466" vy0="-116.017" vz0="2.873" ax="4.002" ay="24.273"
 # az="-40.559" break_y="23.8" break_angle="-5.6" break_length="12.1" pitch_type="CU" type_confidence="1.231"
 # spin_dir="25.513" spin_rate="1161.842"

  # coordinate sets - unsure of what most of these are:
  #    [x, y]            - most likely the pitch location at the plate. unsure of value range or axis direction
  #    [px, pz]
  #    [x0, y0, z0]      - possibly a 3D starting location for the pitch?
  #    [vx0, vy0, vz0]   - possibly a 3D velocity vector?
  #    [pfx_x, pfx_z]    - pfx is a calculated perceived break amount
  #    [ax, ay, az]      - possibly the final location (at the catcher's glove)?

  def pitch_type_desc
    case pitch_type
    when 'FF'
      'Four-seam Fastball'
    when 'FT'
      'Two-seam Fastball'
    when 'FC'
      'Cutter'
    when 'CH'
      'Changeup'
    when 'CU'
      'Curveball'
    when 'SL'
      'Slider'
    when 'SP'
      'Splitter'
    when 'KB', 'KN'  # not sure what the code is for a knuckle, these are guesses
      'Knuckleball'
    when 'PO'
      'Pitch-out'
    else
      pitch_type
    end
  end

  def strike?
    type == 'S'
  end

  def ball?
    type == 'B'
  end

  def in_play?
    type == 'X'
  end

  def foul?
    des == 'Foul'
  end

  def called_strike?
    des == 'Called Strike'
  end

  def swinging_strike?
    des == 'Swinging Strike'
  end

  def swing?
    in_play? || swinging_strike?
  end

end
