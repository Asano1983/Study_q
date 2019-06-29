
.perm.users:([user:`$()] class:`$(); password:())
.perm.sprocs:()!()

.perm.toString:{[x] $[10h=abs type x;x;string x]}
.perm.encrypt:{[u;p] md5 raze .perm.toString p,u}
.perm.add:{[u;c;p] `.perm.users upsert (u;c;.perm.encrypt [u;p]);}
.perm.addUser:{[u;p] .perm.add[u;`user;p]}
.perm.addPoweruser:{[u;p] .perm.add[u;`poweruser;p]}
.perm.addSuperuser:{[u;p] .perm.add[u;`superuser;p]}
.perm.getClass:{[u] .perm.users[u][`class]}
.perm.isSU:{[u] `superuser~.perm.getClass[u]}
.perm.isPU:{[u] `poweruser~.perm.getClass[u]}

.perm.addSproc:{[s] .perm.sprocs,:enlist[s]!enlist enlist`}
.perm.grantSproc:{[s;u] @[`.perm.sprocs;s;union;u];}
.perm.revokeSproc:{[s;u] @[`.perm.sprocs;s;except;u];}
.perm.parse:{[x] if[-10h=type x;x:enlist x]; $[10h=type x;parse x; x]}

//Stored procedure wrapper function - Single point of entry
.perm.executeSproc:{[s;params]
 user:.z.u;
 if[not s in key .perm.sprocs;'string[s]," is not a valid stored procedure"];
 if[(not .perm.isSU user) and not user in .perm.sprocs[s];'"You do not have permission to execute this stored procedure"];
 f:$[1=count (value value s)[1];@;.];
 f[s;params]}

.perm.pg.user:{[user;query]
 if[not ".perm.executeSproc"~.perm.toString first .perm.parse query;'"You only have permission to execute stored procedures:.perm.executeSproc[sprocName;(list;of;params)]"];
 value query}

.perm.is.select:{[x] (count[x] in 5 6 7) and (?)~first x}

//identify whether a variable name is a namespace
.perm.isNamespace:{[x] if[-11h~type x;x:value x]; if[not 99h~type x;:0b];(1#x)~enlist[`]!enlist(::)}

//Recursively retrieve a list of every table in a namespace
.perm.nsTables:{[ns]
 if[ns~`.;:system"a ."];
 if[not .perm.isNamespace[ns];:()];
 raze(` sv' ns,/:system"a ",string ns),.z.s'[` sv' ns,/:system"v ",string ns]}

//Get a list of every table in every namespace
.perm.allTables:{[] raze .perm.nsTables each `$".",/:string each`,key[`]}

.perm.isTableQuery:{[x] any (value each `.perm.is,/:1_key[.perm.is])@\:x}

.perm.getQueryType:{[x]
 f:`.perm.is,/:g:1_key[.perm.is];
 first g where ((value each f)@\:x)}

.perm.tables:([]table:`$();user:`$();permission:`$())
.perm.queries:`select`update`upsert`insert`delete;
.perm.grant:{[t;u;p] if[not p in .perm.queries;'"Not a valid table operation"]; `.perm.tables insert (t;u;p);}
.perm.revoke:{[t;u;p] delete from `.perm.tables where table=t,user=u,permission=p;}
.perm.grantAll:{[t;u] .perm.grant[t;u;] each .perm.queries;}
.perm.getUserPerms:{[t;u] exec distinct permission from .perm.tables where table=t, user=u}

.perm.readOnly:{[x]
 res:first {[q;exe] $[exe;@[value;q;{(`error;x)}]; ()]}[x;] peach 10b;
 if[(2=count res) and `error~first res; $[last[res]~"noupdate";'"You do not have write access";'last res]];
 res}

.perm.validateTableQuery:{[user;query]
 table:first $[-11h~type query;query;query 1];
 p:.perm.getUserPerms[table;user];
 qt:.perm.getQueryType[query];
 if[not qt in p;'"You do not have ",string[qt]," permission on ",string[table]];
 .perm.readOnly[(eval;query)]}

.perm.pg.poweruser:{[user;query]
 if[".perm.executeSproc"~.perm.toString first .perm.parse query; :value query];
 if[.perm.isTableQuery q:.perm.parse[query]; :.perm.readOnly .perm.validateTableQuery[user;q]];
 .perm.readOnly query} 

.perm.queryLog:([]time:`timestamp$();handle:`int$();user:`$();class:`$();hostname:`$();ip:`$();query:();valid:`boolean$();error:())

.perm.accessLog:([]time:`timestamp$();handle:`int$();user:`$();class:`$();hostname:`$();ip:`$();state:`$();error:())

.perm.getIP:{[] `$"."sv string `int$0x0 vs .z.a}

.perm.logQuery:{[q;valid;err]
 ip:.perm.getIP[];
 cls:.perm.getClass[.z.u];
 `.perm.queryLog insert (.z.P;.z.w;.z.u;cls;.z.h;ip;q;valid;enlist err)}

.perm.logValidQuery:{[q] .perm.logQuery[q;1b;""]}

.perm.logInvalidQuery:{[q;err] .perm.logQuery[q;0b;err]}

.perm.logAccess:{[hdl;u;state;msg]
 ip:.perm.getIP[];
 cls:.perm.getClass[u];
 `.perm.accessLog insert (.z.P;hdl;u;cls;.z.h;ip;state;enlist msg)}

.perm.blockAccess:{[usr;msg].perm.logAccess[.z.w;usr;`block; msg]; 0b}

.perm.grantAccess:{[usr] .perm.logAccess[.z.w;usr;`connect;""]; 1b}

.z.pw:{[user;pwd]
 $[not user in key .perm.users;.perm.blockAccess[user;"User does not exist"]; not .perm.encrypt[user;pwd]~.perm.users[user][`password]; .perm.blockAccess[user;"Password Authentication Failed"];
 .perm.grantAccess[user]]} 
 
.z.pg:{[query]
 user:.z.u;
 class:.perm.getClass[user];
 $[class~`superuser; value query;
 class~`poweruser; .perm.pg.poweruser[user;query];
 .perm.pg.user[user;query]]}

// サンプル
t:([] name:`Taro`Jiro; age:30 20)

// サンプルのユーザー
.perm.addUser[`user1;`password]
.perm.addPoweruser[`poweruser1;`password]
.perm.addSuperuser[`superuser1;`password]

.perm.grantAll[`t;`poweruser1]

