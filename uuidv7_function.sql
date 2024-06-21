create or replace function generate_uuid_v7(parameter_timestamp timestamp with time zone) returns uuid as $$
declare
	v_time timestamp with time zone:= null;
	v_secs bigint := null;
	v_msec bigint := null;
	v_usec bigint := null;

	v_timestamp bigint := null;
	v_timestamp_hex varchar := null;

	v_random bigint := null;
	v_random_hex varchar := null;

	v_bytes bytea;

	c_variant bit(64):= x'8000000000000000'; -- RFC-4122 variant: b'10xx...'
begin

	-- Get seconds and micros
--	v_time := clock_timestamp();                       -- ## REPLACED LINE ##
	v_time := parameter_timestamp;
	v_secs := EXTRACT(EPOCH FROM v_time);
	v_msec := mod(EXTRACT(MILLISECONDS FROM v_time)::numeric, 10^3::numeric);
	v_usec := mod(EXTRACT(MICROSECONDS FROM v_time)::numeric, 10^3::numeric);

	-- Generate timestamp hexadecimal (and set version 7)
	v_timestamp := (((v_secs * 10^3) + v_msec)::bigint << 12) | (v_usec << 2);
	v_timestamp_hex := lpad(to_hex(v_timestamp), 16, '0');
	v_timestamp_hex := substr(v_timestamp_hex, 2, 12) || '7' || substr(v_timestamp_hex, 14, 3);

	-- Generate the random hexadecimal (and set variant b'10xx')
	v_random := ((random()::numeric * 2^62::numeric)::bigint::bit(64) | c_variant)::bigint;
	v_random_hex := lpad(to_hex(v_random), 16, '0');

	-- Concat timestemp and random hexadecimal
	v_bytes := decode(v_timestamp_hex || v_random_hex, 'hex');

	return encode(v_bytes, 'hex')::uuid;

end $$ language plpgsql;

create or replace function extract_timestamp(parameter_uuid uuid) returns bigint as $$
declare
	v_uuid_hex varchar := null;
	v_timestamp bigint := null;
	v_timestamp_hex varchar := null;
begin

	v_uuid_hex := replace(parameter_uuid::varchar, '-', '');
	v_timestamp_hex := substring(v_uuid_hex, 1, 12) || substring(v_uuid_hex, 14, 3);
	v_timestamp := ('x'||lpad(v_timestamp_hex,16,'0'))::bit(64)::bigint;

	return mod(v_timestamp >> 12, (10^3)::bigint);

end $$ language plpgsql;

SELECT generate_uuid_v7(now());
SELECT generate_uuid_v7(now());
