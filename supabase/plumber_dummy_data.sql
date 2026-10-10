-- =============================================================================
-- PLUMBER DUMMY DATA
-- =============================================================================
-- This file creates dummy plumber jobs for testing the plumber functionality
--
-- Test Plumber Phone: 9999000004
-- Run this AFTER the plumber user has logged in at least once
-- =============================================================================

-- First, get the plumber's user ID
-- Replace this with actual plumber ID after login
-- You can get it by running: SELECT id FROM users WHERE phone_number = '9999000004';

-- For now, we'll use a variable approach
DO $$
DECLARE
  plumber_user_id UUID;
BEGIN
  -- Get the plumber user ID
  SELECT id INTO plumber_user_id
  FROM users
  WHERE phone_number = '9999000004' AND role = 'plumber';

  -- Check if plumber exists
  IF plumber_user_id IS NULL THEN
    RAISE NOTICE 'Plumber user not found. Please login with phone 9999000004 first!';
    RETURN;
  END IF;

  RAISE NOTICE 'Creating jobs for plumber ID: %', plumber_user_id;

  -- Delete existing jobs for this plumber (for clean testing)
  DELETE FROM plumber_jobs WHERE plumber_id = plumber_user_id;

  -- Insert Active Jobs (in_progress status)
  INSERT INTO plumber_jobs (
    plumber_id, title, description, location, status, priority,
    customer_name, customer_phone, customer_address,
    scheduled_date, created_at, updated_at
  ) VALUES
  (
    plumber_user_id,
    'Install bathroom fittings',
    'Install new bathroom fittings including shower, taps, and accessories. Premium fixtures from Jaquar brand.',
    'Andheri West, Mumbai',
    'in_progress',
    'high',
    'Raj Kumar',
    '9876543210',
    '301, Shanti Apartments, S.V. Road, Andheri West, Mumbai - 400058',
    CURRENT_DATE,
    NOW(),
    NOW()
  ),
  (
    plumber_user_id,
    'Fix water heater issue',
    'Water heater not heating properly. Need to check thermostat and heating element.',
    'Bandra East, Mumbai',
    'in_progress',
    'urgent',
    'Priya Mehta',
    '9876543211',
    'B-402, Sea View Tower, Bandra East, Mumbai - 400051',
    CURRENT_DATE,
    NOW(),
    NOW()
  );

  -- Insert Scheduled Jobs (assigned status)
  INSERT INTO plumber_jobs (
    plumber_id, title, description, location, status, priority,
    customer_name, customer_phone, customer_address,
    scheduled_date, created_at, updated_at
  ) VALUES
  (
    plumber_user_id,
    'Fix leaking pipe',
    'Kitchen sink pipe is leaking. Customer reports water dripping from under the sink.',
    'Bandra East, Mumbai',
    'assigned',
    'normal',
    'Priya Sharma',
    '9876543212',
    '12/A, Golden Heights, Linking Road, Bandra East, Mumbai - 400051',
    CURRENT_DATE + INTERVAL '1 day',
    NOW(),
    NOW()
  ),
  (
    plumber_user_id,
    'Kitchen sink installation',
    'Install new stainless steel kitchen sink with faucet. Materials provided by customer.',
    'Powai, Mumbai',
    'assigned',
    'normal',
    'Amit Patel',
    '9876543213',
    '15, Lake View Residency, Powai, Mumbai - 400076',
    CURRENT_DATE + INTERVAL '2 days',
    NOW(),
    NOW()
  ),
  (
    plumber_user_id,
    'Bathroom renovation plumbing',
    'Complete bathroom plumbing work for renovation. Includes new pipeline installation.',
    'Andheri East, Mumbai',
    'assigned',
    'high',
    'Suresh Reddy',
    '9876543214',
    '8th Floor, Sky Towers, Andheri East, Mumbai - 400069',
    CURRENT_DATE + INTERVAL '3 days',
    NOW(),
    NOW()
  ),
  (
    plumber_user_id,
    'Geyser installation',
    'Install new 25L geyser in bathroom. Electrical and plumbing connections required.',
    'Goregaon West, Mumbai',
    'assigned',
    'normal',
    'Neha Desai',
    '9876543215',
    'C-204, Royal Palace, Goregaon West, Mumbai - 400104',
    CURRENT_DATE + INTERVAL '4 days',
    NOW(),
    NOW()
  );

  -- Insert Completed Jobs (completed status)
  INSERT INTO plumber_jobs (
    plumber_id, title, description, location, status, priority,
    customer_name, customer_phone, customer_address,
    scheduled_date, completed_date, plumber_notes, created_at, updated_at
  ) VALUES
  (
    plumber_user_id,
    'Bathroom repair',
    'Fixed leaking tap and replaced washer. Also checked all other fittings.',
    'Juhu, Mumbai',
    'completed',
    'normal',
    'Neha Singh',
    '9876543216',
    '5/B, Ocean View, Juhu Tara Road, Juhu, Mumbai - 400049',
    CURRENT_DATE - INTERVAL '1 day',
    CURRENT_DATE - INTERVAL '1 day' + INTERVAL '3 hours',
    'Replaced tap washer and tightened all connections. No further issues.',
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '1 day'
  ),
  (
    plumber_user_id,
    'Water heater installation',
    'Installed new 15L instant water heater in bathroom. Tested all safety features.',
    'Goregaon, Mumbai',
    'completed',
    'normal',
    'Rohit Mehta',
    '9876543217',
    '10, Green Valley Society, Goregaon West, Mumbai - 400104',
    CURRENT_DATE - INTERVAL '2 days',
    CURRENT_DATE - INTERVAL '2 days' + INTERVAL '2 hours',
    'Installation completed successfully. Customer very satisfied with work.',
    NOW() - INTERVAL '3 days',
    NOW() - INTERVAL '2 days'
  ),
  (
    plumber_user_id,
    'Washing machine pipe setup',
    'Connected water supply and drainage for new washing machine.',
    'Malad West, Mumbai',
    'completed',
    'low',
    'Kavita Joshi',
    '9876543218',
    '7th Floor, Star Residency, Malad West, Mumbai - 400064',
    CURRENT_DATE - INTERVAL '5 days',
    CURRENT_DATE - INTERVAL '5 days' + INTERVAL '1 hour',
    'Quick and simple job. Connections done properly.',
    NOW() - INTERVAL '6 days',
    NOW() - INTERVAL '5 days'
  ),
  (
    plumber_user_id,
    'Kitchen tap replacement',
    'Replaced old kitchen tap with new sensor tap. Updated plumbing as needed.',
    'Versova, Mumbai',
    'completed',
    'normal',
    'Deepak Kumar',
    '9876543219',
    'A-501, Sunset Apartments, Versova, Mumbai - 400061',
    CURRENT_DATE - INTERVAL '7 days',
    CURRENT_DATE - INTERVAL '7 days' + INTERVAL '2 hours',
    'Sensor tap installed and calibrated. Customer trained on usage.',
    NOW() - INTERVAL '8 days',
    NOW() - INTERVAL '7 days'
  ),
  (
    plumber_user_id,
    'Toilet flush repair',
    'Fixed dual flush system that was not working properly.',
    'Kandivali East, Mumbai',
    'completed',
    'normal',
    'Anil Sharma',
    '9876543220',
    '12/C, Happy Homes, Kandivali East, Mumbai - 400101',
    CURRENT_DATE - INTERVAL '10 days',
    CURRENT_DATE - INTERVAL '10 days' + INTERVAL '1 hour',
    'Replaced flush mechanism. Working perfectly now.',
    NOW() - INTERVAL '11 days',
    NOW() - INTERVAL '10 days'
  );

  RAISE NOTICE 'Successfully created dummy jobs for plumber!';
  RAISE NOTICE 'Active jobs: 2';
  RAISE NOTICE 'Scheduled jobs: 4';
  RAISE NOTICE 'Completed jobs: 5';

END $$;

-- Verify the data
SELECT
  status,
  COUNT(*) as job_count
FROM plumber_jobs
WHERE plumber_id = (SELECT id FROM users WHERE phone_number = '9999000004')
GROUP BY status
ORDER BY status;
