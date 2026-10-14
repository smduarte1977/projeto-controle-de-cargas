-- Projeto de Controle de Cargas — tabela de Cargo Manifestos (manifestos.html)
-- Rode UMA vez no Supabase: SQL Editor → New query → cole tudo → Run.
-- Mesmo formato das tabelas "cargas" e "meta" (id texto + data jsonb) e os mesmos perfis do Deck Cargo Plan.
-- Diferença: manifestos têm custos (R$), então só USUÁRIOS GC e ADMINISTRADORES leem. Os demais não veem nada.

create table if not exists public.manifestos (
  id            text primary key,                 -- ex.: m-047-2026
  data          jsonb not null default '{}'::jsonb,
  atualizado_em timestamptz not null default now()
);

create or replace function public.manifestos_touch() returns trigger
language plpgsql as $$ begin new.atualizado_em := now(); return new; end $$;
drop trigger if exists manifestos_touch on public.manifestos;
create trigger manifestos_touch before insert or update on public.manifestos
  for each row execute function public.manifestos_touch();

-- busca rápida por código e por TAG dentro do jsonb
create index if not exists manifestos_codigo_idx on public.manifestos ((data->>'codigo'));
create index if not exists manifestos_data_gin   on public.manifestos using gin (data jsonb_path_ops);

alter table public.manifestos enable row level security;

-- Cargo Manifestos: só USUÁRIO GC e ADMINISTRADOR aprovados (papéis do arquivo supabase/papeis_gc.sql)
create or replace function public.manifestos_aprovado() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.perfis p
                 where p.id = auth.uid() and p.status = 'aprovado' and p.papel in ('usuario_gc','admin'));
$$;
create or replace function public.manifestos_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.perfis p
                 where p.id = auth.uid() and p.papel = 'admin' and coalesce(p.status,'') not in ('pendente','recusado'));
$$;

drop policy if exists manifestos_ler     on public.manifestos;
drop policy if exists manifestos_inserir on public.manifestos;
drop policy if exists manifestos_editar  on public.manifestos;
drop policy if exists manifestos_apagar  on public.manifestos;

create policy manifestos_ler     on public.manifestos for select to authenticated using (public.manifestos_aprovado());
create policy manifestos_inserir on public.manifestos for insert to authenticated with check (public.manifestos_aprovado());
-- manifesto ENCERRADO só pode ser alterado por administrador (ex.: corrigir assinatura)
create policy manifestos_editar  on public.manifestos for update to authenticated
  using (public.manifestos_aprovado() and (coalesce(data->>'status','') <> 'ENCERRADO' or public.manifestos_admin()))
  with check (public.manifestos_aprovado());
-- o site nunca apaga (rascunho excluído = data.excluido); apagar de verdade só administrador
create policy manifestos_apagar  on public.manifestos for delete to authenticated using (public.manifestos_admin());

grant select, insert, update, delete on public.manifestos to authenticated;
revoke all on public.manifestos from anon;

-- atualização em tempo real na página (igual às cargas)
do $$ begin
  alter publication supabase_realtime add table public.manifestos;
exception when duplicate_object then null; end $$;
