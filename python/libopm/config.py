"""! OPM Config library.
@author zer0
@date   2015-12-16
"""
# -*- coding: utf-8 -*-

import xml.etree.ElementTree as ET
import xml.dom.minidom

TAG_ROOT     = 'opm'
TAG_REMOTE   = 'remote'
TAG_PROTOCOL = 'protocol'
TAG_USER     = 'user'
TAG_HOST     = 'host'
TAG_PORT     = 'root'
TAG_PATH     = 'path'

ATTR_VERSION = 'version'
ATTR_NAME    = 'name'

DEFAULT_NAME     = 'origin'
DEFAULT_PROTOCOL = 'sftp'
DEFAULT_USER     = 'root'
DEFAULT_HOST     = 'localhost'
DEFAULT_PORT     = '22'
DEFAULT_PATH     = '/var/opm'

VERSION_MIN_MAJOR = 0
VERSION_MIN_MINOR = 1
VERSION_MIN = '{}.{}'.format(VERSION_MIN_MAJOR, VERSION_MIN_MINOR)


class ConfigException(Exception):
    """! Config exception class.
    @author zer0
    @date   2015-12-04
    """

    def __init__(self, message):
        self.message = message

    def __str__(self):
        return repr(self.message)


def appendElement(parent, tag, text):
    child = ET.Element(tag)
    child.text = text
    parent.append(child)


# ------------
# XML Strings.
# ------------

def getConfigXmlString(version, name, protocol, user, host, port, path):
    """! Arguments -> XML String. """
    tag_root = ET.Element(TAG_ROOT)
    tag_root.set(ATTR_VERSION, version)

    tag_remote = ET.Element(TAG_REMOTE)
    tag_remote.set(ATTR_NAME, name)
    tag_root.append(tag_remote)

    appendElement(tag_remote, TAG_PROTOCOL, protocol)
    appendElement(tag_remote, TAG_USER, user)
    appendElement(tag_remote, TAG_HOST, host)
    appendElement(tag_remote, TAG_PORT, port)
    appendElement(tag_remote, TAG_PATH, path)

    return ET.tostring(tag_root)


def getDefaultConfigXmlString():
    """! Default settings -> XML String. """
    return getConfigXmlString(VERSION_MIN,
                              DEFAULT_NAME,
                              DEFAULT_PROTOCOL,
                              DEFAULT_USER,
                              DEFAULT_HOST,
                              DEFAULT_PORT,
                              DEFAULT_PATH)


def getConfigXmlStringWithMap(config_map):
    """! Configure map -> XML String. """
    return getConfigXmlString(config_map[ATTR_VERSION],
                              config_map[ATTR_NAME],
                              config_map[TAG_PROTOCOL],
                              config_map[TAG_USER],
                              config_map[TAG_HOST],
                              config_map[TAG_PORT],
                              config_map[TAG_PATH])


# ---------------
# Configure Maps.
# ---------------

def getConfigMap(version, name, protocol, user, host, port, path):
    """! Arguments -> Configure map. """
    return {
        ATTR_VERSION: version,
        ATTR_NAME   : name,
        TAG_PROTOCOL: protocol,
        TAG_USER    : user,
        TAG_HOST    : host,
        TAG_PORT    : port,
        TAG_PATH    : path
    }


def getDefaultConfigMap():
    """! Default settings -> Configure map. """
    return getConfigMap(VERSION_MIN,
                        DEFAULT_NAME,
                        DEFAULT_PROTOCOL,
                        DEFAULT_USER,
                        DEFAULT_HOST,
                        DEFAULT_PORT,
                        DEFAULT_PATH)


def getConfigMapWithInteractive():
    """! Interactive -> Configure map. """
    version  = VERSION_MIN
    name     = raw_input('Remote name [{}]:'.format(DEFAULT_NAME))
    protocol = raw_input('Protocol name [{}]:'.format(DEFAULT_PROTOCOL))
    user     = raw_input('User name [{}]:'.format(DEFAULT_USER))
    host     = raw_input('Host [{}]:'.format(DEFAULT_HOST))
    port     = raw_input('Port number [{}]:'.format(DEFAULT_PORT))
    path     = raw_input('Remote Path [{}]:'.format(DEFAULT_PATH))

    if not name:
        name = DEFAULT_NAME
    if not protocol:
        protocol = DEFAULT_PROTOCOL
    if not user:
        user = DEFAULT_USER
    if not host:
        host = DEFAULT_HOST
    if not port:
        port = DEFAULT_PORT
    if not path:
        path = DEFAULT_PATH

    return getConfigMap(version, name, protocol, user, host, port, path)


# -------------
# XML File I/O.
# -------------

def writeConfigXmlWithMap(xml_path, config_map=None):
    """! Configure map -> XML file.
    @param xml_path   [in] XML file path.
    @param config_map [in] Configure map.
    """

    xml_body = ''

    if config_map:
        xml_body = getConfigXmlStringWithMap(config_map)
    else:
        xml_body = getDefaultConfigXmlString()

    with open(xml_path, 'wb') as f:
        f.write(xml.dom.minidom.parseString(xml_body).toprettyxml())


def readConfigXml(xml_path):
    """! XML file -> Configure map.
    @param xml_path   [in] XML file path.
    @return Configure map.
    """
    tag_root = ET.ElementTree().parse(xml_path)

    # check the root tag.
    if tag_root.tag != TAG_ROOT:
        raise ConfigException('Not found {} tag.'.format(TAG_ROOT))

    tag_remote   = tag_root.find(TAG_REMOTE)

    tag_protocol = tag_remote.find(TAG_PROTOCOL)
    tag_user     = tag_remote.find(TAG_USER)
    tag_host     = tag_remote.find(TAG_HOST)
    tag_port     = tag_remote.find(TAG_PORT)
    tag_path     = tag_remote.find(TAG_PATH)

    return getConfigMap(tag_root.attrib[ATTR_VERSION],
                        tag_remote.attrib[ATTR_NAME],
                        tag_protocol.text,
                        tag_user.text,
                        tag_host.text,
                        tag_port.text,
                        tag_path.text)


# ------
# Class.
# ------

class Config(object):
    """! Configure class.
    @author zer0
    @date   2015-12-05
    """
    def __init__(self, config_map=None):
        if config_map:
            self.config_map = config_map

    def readConfigXml(self, xml_path):
        self.config_map = readConfigXml(xml_path)

    def setConfigMap(self, config_map):
        self.config_map = config_map

    def getVersion(self):
        return self.config_map[ATTR_VERSION]
    def getName(self):
        return self.config_map[ATTR_NAME]
    def getProtocol(self):
        return self.config_map[TAG_PROTOCOL]
    def getUser(self):
        return self.config_map[TAG_USER]
    def getHost(self):
        return self.config_map[TAG_HOST]
    def getPort(self):
        return self.config_map[TAG_PORT]
    def getPath(self):
        return self.config_map[TAG_PATH]

    def getUserOrInteractive(self):
        user = self.getUser()
        if not user:
            return raw_input('User name:')
        else:
            return user

    def getUri(self):
        protocol = self.getProtocol()
        host = self.getHost()
        port = self.getPort()
        path = self.getPath()

        if path[0] != '/':
            path = '/' + path

        return '{}://{}:{}{}'.format(protocol, host, port, path)


if __name__ == '__main__':
    pass
