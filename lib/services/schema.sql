-- Employees table
CREATE TABLE IF NOT EXISTS employees (
  employee_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  department TEXT DEFAULT 'General',
  designation TEXT NOT NULL,
  mobile_no TEXT DEFAULT '',
  email TEXT DEFAULT '',
  password TEXT DEFAULT '',
  room TEXT NOT NULL
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id TEXT PRIMARY KEY,
  employee JSONB NOT NULL,
  work_type TEXT DEFAULT '',
  priority TEXT DEFAULT 'normal',
  status TEXT DEFAULT 'Pending',
  note TEXT DEFAULT '',
  assigned_by TEXT DEFAULT 'Admin',
  assigned_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  seen_by_employee BOOLEAN DEFAULT false,
  seen_by_admin BOOLEAN DEFAULT true
);

-- Activity log table
CREATE TABLE IF NOT EXISTS activity_log (
  id SERIAL PRIMARY KEY,
  task_id TEXT,
  employee_name TEXT,
  work_type TEXT,
  status TEXT,
  time TIMESTAMPTZ DEFAULT now()
);

-- Disable RLS for development/testing
ALTER TABLE employees DISABLE ROW LEVEL SECURITY;
ALTER TABLE tasks DISABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log DISABLE ROW LEVEL SECURITY;

-- Reload schema cache
NOTIFY pgrst, 'reload schema';