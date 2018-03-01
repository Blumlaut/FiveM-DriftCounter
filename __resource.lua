resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_script "driftcounter_c.lua"

server_script "driftcounter_s.lua"
files {
	'stats.xml'
}

data_file 'MP_STATS_DISPLAY_LIST_FILE' 'stats.xml'