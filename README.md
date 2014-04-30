# macfind
mac address snmp get (cisco, dlink oids)  
Получение таблицы мак адресов с коммутаторов посредством SNMP. На вход - ип и комьюнити, на выходе таблица маков.

## Hardware
Скорее всего будет работать и на другом оборудовании этих вендоров, просто под рукой нет.
### find_cisco.pl  
- 2960
- 2970
- 2950
 
### find_cisco_old.pl  
- 2900

### find_dlink.pl  
- DES-1210
- DGS-1210

## use
```
./find_dlink.pl 192.168.1.200 public  
00016c012f34;Slot0/50;1  
00037e004364;Slot0/52;2
...
```
> (mac;port;vlan)
