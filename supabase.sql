-- ============================================================
-- 数据分析后台 · 数据库初始化脚本
-- 用法：Supabase 控制台 → SQL Editor → 新建查询 → 粘贴全部 → 点 Run
-- ============================================================

-- 1) 作答表：一份作答一条记录
create table if not exists public.responses (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  ts         text,        -- 作答时间（ISO 字符串）
  basic      jsonb,       -- 基础信息 {年级,性别,专业,时长,平台,遭遇,求助对象,求助渠道}
  answers    jsonb,       -- 27 道题作答 {q1..q27}
  result     jsonb        -- 计算结果 {C,A,GAP,OB,AI,HS,dom,form,type,tags,weak,D}
);

-- 2) 开启行级安全（RLS）：默认拒绝一切访问，只放行下面的策略
alter table public.responses enable row level security;

-- 3) 访客（anon）只能匿名提交一份作答，看不到、改不了、删不了
drop policy if exists "允许匿名提交" on public.responses;
create policy "允许匿名提交" on public.responses
  for insert to anon with check (true);

-- 4) 只有登录的后台账号（authenticated）能查看全部数据
drop policy if exists "允许登录后台查看" on public.responses;
create policy "允许登录后台查看" on public.responses
  for select to authenticated using (true);

-- 5) 只有登录的后台账号能清空数据（可选，谨慎使用）
drop policy if exists "允许登录后台删除" on public.responses;
create policy "允许登录后台删除" on public.responses
  for delete to authenticated using (true);
