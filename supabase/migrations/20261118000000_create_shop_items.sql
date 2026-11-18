-- 쇼핑 리스트 항목 테이블 (Supabase MCP로 적용한 마이그레이션 기록)
create table public.shop_items (
  id uuid primary key default gen_random_uuid(),
  text text not null check (char_length(text) between 1 and 200),
  done boolean not null default false,
  created_at timestamptz not null default now()
);

comment on table public.shop_items is '로그인 없이 모두가 함께 쓰는 쇼핑 리스트 항목';

create index shop_items_created_at_idx on public.shop_items (created_at);

-- RLS는 켜 두고, 지금은 로그인 없이 누구나 읽고 쓸 수 있게 모두 허용한다
alter table public.shop_items enable row level security;

grant select, insert, update, delete on public.shop_items to anon, authenticated;

create policy "누구나 조회" on public.shop_items
  for select to anon, authenticated using (true);
create policy "누구나 추가" on public.shop_items
  for insert to anon, authenticated with check (true);
create policy "누구나 수정" on public.shop_items
  for update to anon, authenticated using (true) with check (true);
create policy "누구나 삭제" on public.shop_items
  for delete to anon, authenticated using (true);

-- 실시간 동기화를 위해 Realtime 발행 대상에 추가
alter publication supabase_realtime add table public.shop_items;
