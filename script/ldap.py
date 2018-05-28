
import os
import sys
import subprocess
import re
import base64
from urlparse import urlparse

pattern1 = "(\w+): (.+)"
pattern2 = "(\w+):: (.+)"
authz_path = '/etc/apache2/auth/authz.acl'

url = os.environ['LDAP_URL']
comp = urlparse(url)
host = comp[0] + '://' + comp[1]
user = os.environ['LDAP_BIND_DN']
password = os.environ['LDAP_PASSWORD']
svn_group_basedn = os.environ['LDAP_SVN_GROUP_DN']
svn_authz_basedn = os.environ['LDAP_AUTHZ_DN']


def parse(iters):

    entries = []
    entry = None
    for line in iters:
        line = line.strip()

        if line.startswith("dn"):
            if entry:
                raise Exception("parse line error: " + line)
            entry = {}
            k, v = parseLine(line)
            entry[k] = [v]
        elif line == "":
            if entry:
                entries.append(entry)
                entry = None
        else:
            k, v = parseLine(line)
            if entry.has_key(k):
                entry[k].append(v)
            else:
                entry[k] = [v]
    return entries


def parseLine(line):
    m = re.match(pattern1, line)
    if m:
        k, v = m.groups()
    else:
        m = re.match(pattern2, line)
        if not m:
            raise Exception("parse line error: " + line)
        k, v = m.groups()
        v = base64.decodestring(v)
    return k, v

def ldap_search(host, user, password, basedn, search):
    cmd = ['ldapsearch', '-H', host, '-x']
    if user:
        cmd += ['-w', password, '-D', user]
    cmd += ['-LLL', '-b', basedn, search]
    return subprocess.check_output(cmd)

def format(groups, section, out):
    
    
    g = {}
    permission = []
    for item in section:
        cn = item["cn"][0]
        permission.append('\n')
        permission.append('[%s]\n' % (cn))
        for t in item['priAuthzPolicy']:
            n = t.split('=', 1)[0].strip()
            if n.startswith('@'):
                g[n[1:]] = True
            permission.append(t + '\n')
    
    out.write("[groups]\n")
    for group in groups:
        cn = group["cn"][0]
        members = group["uniqueMember"]
        members = map(lambda x: x.split(',',1)[0].split('=')[1], members)
        line = "%s = %s\n" % (cn, ",".join(members))
        out.write(line)
        if g.has_key(cn):
            del g[cn]
    for k in g:
        out.write('%s = \n' % k)
    out.writelines(permission)

def main():
    output = ldap_search(host, user, password, svn_group_basedn, '(objectClass=groupOfUniqueNames)')
    membership = parse(output.splitlines())

    output = ldap_search(host, user, password, svn_authz_basedn, '(objectClass=priAuthzSection)')
    authz = parse(output.splitlines())

    with open(authz_path, 'wb') as f:
        format(membership, authz, f)

main()


