# -*- coding: utf-8 -*-

from json import dumps
from typing import Dict, List, Optional, Union

from wsdiscovery.discovery import ThreadedWSDiscovery


def ws_discovery_dict() -> List[Dict[str, any]]:
    wsd = ThreadedWSDiscovery()
    wsd.start()
    try:
        result = list()
        for service in wsd.searchServices():
            item = dict()
            item["EPR"] = service.getEPR()
            item["InstanceId"] = service.getInstanceId()
            item["MessageNumber"] = service.getMessageNumber()
            item["MetadataVersion"] = service.getMetadataVersion()
            item["Scopes"] = [s.getValue() for s in service.getScopes()]
            item["Types"] = [t.getFullname() for t in service.getTypes()]
            item["XAddrs"] = [a for a in service.getXAddrs()]
            result.append(item)
        return result
    finally:
        wsd.stop()


def ws_discovery_json(indent: Optional[Union[int, str]] = None, sort_keys=False) -> str:
    return dumps(ws_discovery_dict(), indent=indent, sort_keys=sort_keys)


def main():
    print(ws_discovery_json(indent=4, sort_keys=True))


if __name__ == "__main__":
    main()
