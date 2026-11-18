-- shop_items 항목마다 주인(user_id)을 두고, 로그인한 사용자가 자기 항목만 다루게 한다
-- (Supabase SQL Editor에서 직접 실행한 내용의 기록)

-- 1) 주인 열 추가: 새 항목은 DB가 로그인한 사용자(auth.uid())로 채운다 (트리거 없음)
alter table public.shop_items
  add column user_id uuid default auth.uid()
    references auth.users (id) on delete cascade;

-- 2) 주인이 없는 기존 항목은 지운 뒤, 주인을 반드시 갖도록 한다
delete from public.shop_items where user_id is null;

alter table public.shop_items
  alter column user_id set not null;

create index shop_items_user_id_idx on public.shop_items (user_id);

comment on table public.shop_items is '로그인한 사용자마다 따로 쓰는 쇼핑 리스트 항목';
comment on column public.shop_items.user_id is '항목 주인 (기본값 auth.uid())';

-- 3) 모두 허용 정책을 지운다
drop policy "누구나 조회" on public.shop_items;
drop policy "누구나 추가" on public.shop_items;
drop policy "누구나 수정" on public.shop_items;
drop policy "누구나 삭제" on public.shop_items;

-- 4) 로그인한 사용자는 자기 항목만 보고, 넣고, 고치고, 지울 수 있다
--    (select auth.uid())로 감싸 행마다 다시 계산하지 않게 한다
create policy "자기 항목 조회" on public.shop_items
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "자기 항목 추가" on public.shop_items
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "자기 항목 수정" on public.shop_items
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "자기 항목 삭제" on public.shop_items
  for delete to authenticated
  using ((select auth.uid()) = user_id);
