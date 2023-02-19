#! /usr/bin/env python3

import psycopg2
import psycopg2.extensions
import os
import os.path
import subprocess

psycopg2.extensions.register_type(psycopg2.extensions.UNICODE)
psycopg2.extensions.register_type(psycopg2.extensions.UNICODEARRAY)

def git_commit(entry):
	env = os.environ.copy()
	env['GIT_COMMITTER_DATE'] = entry['updated'].strftime('%Y-%m-%dT%H:%M:%SZ')
	env['GIT_AUTHOR_DATE'] = env['GIT_COMMITTER_DATE']
	env['GIT_COMMITTER_NAME'] = entry['user']
	env['GIT_AUTHOR_NAME'] = env['GIT_COMMITTER_NAME']
	env['GIT_COMMITTER_EMAIL'] = entry['email']
	env['GIT_AUTHOR_EMAIL'] = env['GIT_COMMITTER_EMAIL']

	p = subprocess.Popen(['/usr/bin/git', 'add', entry['filename']], env=env)
	p.wait()
	p = subprocess.Popen(['/usr/bin/git', 'commit', '-m', entry['comment']], env=env)
	p.wait()

def download_attachment(entry):
	subprocess.call(['/usr/bin/curl', 'https://www.open-mesh.org/attachments/download/' + str(entry['id']), '-o', entry['filename']])

conn = psycopg2.connect(database="redmine_default")
conn.set_client_encoding('UTF-8')

cur = conn.cursor()
cur.execute('''
SELECT wiki_content_versions.data,wiki_content_versions.updated_on,wiki_content_versions.comments,wiki_pages.title,users.id,users.firstname,users.lastname,projects.identifier,email_addresses.address
FROM wiki_content_versions
LEFT JOIN wiki_pages ON wiki_content_versions.page_id = wiki_pages.id
LEFT JOIN users ON wiki_content_versions.author_id = users.id
LEFT JOIN wikis ON wiki_pages.wiki_id = wikis.id
LEFT JOIN projects ON wikis.project_id = projects.id
LEFT JOIN email_addresses ON users.id = email_addresses.user_id AND email_addresses.is_default
ORDER BY wiki_content_versions.updated_on,wiki_content_versions.id;
''')
rows = cur.fetchall()

entries = []
for r in rows:
	if not r[4]:
		user = 'B.A.T.M.A.N. developer'
		email = 'postmaster@open-mesh.org'
	elif r[4] == 2 or r[4] == 773:
		user = 'Sven Eckelmann'
		email = 'sven@narfation.org'
	else:
		user = r[5] + ' ' + r[6]
		email = r[8]

	if r[2]:
		comment = 'doc: ' + os.path.join(r[7], r[3]) + ': ' + r[2]
	else:
		comment = 'doc: ' + os.path.join(r[7], r[3])

	entries.append({
		'type': 'wiki',
		'user': user,
		'email': email,
		'filename': os.path.join(r[7], r[3] + '.textile'),
		'comment': comment,
		'updated': r[1],
		'data': r[0],
	})

cur = conn.cursor()
cur.execute('''
SELECT attachments.filename,attachments.created_on,users.id,users.firstname,users.lastname,email_addresses.address,attachments.id,projects.identifier
FROM attachments
LEFT JOIN users ON attachments.author_id = users.id
LEFT JOIN email_addresses ON users.id = email_addresses.user_id AND email_addresses.is_default
LEFT JOIN wiki_pages ON attachments.container_id = wiki_pages.id
LEFT JOIN wikis ON wiki_pages.wiki_id = wikis.id
LEFT JOIN projects ON wikis.project_id = projects.id
WHERE attachments.container_type = 'WikiPage'
ORDER BY attachments.created_on,attachments.id;
''')
rows = cur.fetchall()

for r in rows:
	if not r[2]:
		user = 'B.A.T.M.A.N. developer'
		email = 'postmaster@open-mesh.org'
	elif r[2] == 2 or r[2] == 773:
		user = 'Sven Eckelmann'
		email = 'sven@narfation.org'
	else:
		user = r[3] + ' ' + r[4]
		email = r[5]

	comment = 'doc: ' + os.path.join(r[7], r[0])

	entries.append({
		'type': 'attachment',
		'user': user,
		'email': email,
		'filename': os.path.join(r[7], r[0]),
		'comment': comment,
		'updated': r[1],
		'id': r[6],
	})

entries.sort(key=lambda d: d['updated'])

for entry in entries:
	path = os.path.dirname(entry['filename'])
	if not os.path.isdir(path):
		os.makedirs(path)

	if entry['type'] == 'wiki':
		open(entry['filename'], 'wb').write(entry['data'])
	elif entry['type'] == 'attachment':
		download_attachment(entry)

	git_commit(entry)
