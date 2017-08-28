/**
 * Created by sam on 13.03.2015.
 */
import {hash, param} from 'phovea_core/src';
import {EventHandler} from 'phovea_core/src/event';
import {getAPIJSON} from 'phovea_core/src/ajax';


export function uc() {
  return hash.getProp('uc', param.getProp('uc', 'dblp'));
}

export interface INode {
  id: string;
}
export interface IEdge {
  id: string;
}

export interface IPath {
  nodes: INode[];
  edges: IEdge[];
}

export interface IQuery {
  serialize(): any;
}

export interface IServerSearchResult {
  value: number;
  label: string;
  id: string;
  labels: string[];
}


function asMessage(type: string, msg: any) {
  msg.uc = uc();
  return JSON.stringify({type, data: msg});
}

export function resolveConfig() {
  return getAPIJSON(`/pathway/config.json`, {uc: uc()});
}

export default class ServerSearch extends EventHandler {
  static readonly EVENT_QUERY_PATH = 'query_path';
  static readonly EVENT_NEIGHBOR = 'neighbor_neighbor';
  static readonly EVENT_PATH = 'found';
  static readonly EVENT_QUERY_DONE = 'query_done';

  private static readonly MSG_NEW_NODE = 'new_node';
  private static readonly MSG_NEW_EDGE = 'new_relationship';
  private static readonly SERVER_MSG_QUERY = 'query';
  private static readonly SERVER_MSG_NEIGBOR = 'neighbor';
  private static readonly SERVER_MSG_FIND = 'find';

  static readonly EVENT_WS_READY = 'ws_ready';
  static readonly EVENT_WS_CLOSED = 'ws_closed';

  private socket: WebSocket = null;
  private readonly initialMessages: string[] = [];

  private readonly searchCache = new Map<string, Map<string, any>>();
  private readonly nodeLookup = new Map<string, INode>();
  private readonly edgeLookup = new Map<string, IEdge>();

  private extendPath(path: IPath) {
    return {
      nodes: path.nodes.map((n) => this.extendNode(n)),
      edges: path.edges.map((n) => this.extendRel(n))
    };
  }

  private extendNode(node: INode) {
    if (this.nodeLookup.has(node.id)) {
      return this.nodeLookup.get(node.id);
    }
    return node;
  }

  private extendRel(edge: IEdge) {
    if (this.edgeLookup.has(edge.id)) {
      return this.edgeLookup.get(edge.id);
    }
    return edge;
  }

  private onMessage(msg: {type: string, data: any}) {
    switch (msg.type) {
      case ServerSearch.EVENT_QUERY_PATH:
        msg.data.path = this.extendPath(msg.data.path);
        break;
      case ServerSearch.EVENT_NEIGHBOR:
        msg.data.neighbor = this.extendNode(msg.data.neighbor);
        msg.data.edge = msg.data.neighbor._edge = this.extendRel(msg.data.edge);
        break;
      case ServerSearch.EVENT_PATH:
        const n = this.extendNode(msg.data.node);
        msg.data.path = {nodes: [n], edges: []};
        delete msg.data.node;
        break;
      case ServerSearch.MSG_NEW_NODE:
        const node: INode = msg.data;
        this.nodeLookup.set(node.id, node);
        return;
      case ServerSearch.MSG_NEW_EDGE:
        const edge: IEdge = msg.data;
        this.edgeLookup.set(edge.id, edge);
        return;
    }
    this.fire(msg.type, msg.data);
  }


  private send(type: string, msg: any) {
    if (!this.socket) {
      this.initialMessages.push(asMessage(type, msg));
      const s = new WebSocket(`${location.protocol === 'https:' ? 'wss' : 'ws'}://${document.domain}:${location.port}/api/pathway/query`);
      this.fire('ws_open');
      s.onmessage = (msg) => this.onMessage(JSON.parse(msg.data));
      s.onopen = () => {
        this.socket = s;
        this.initialMessages.forEach((msg) => s.send(msg));
        this.initialMessages.splice(0, this.initialMessages.length);
        this.fire(ServerSearch.EVENT_WS_READY);
      };
      s.onclose = () => {
        this.socket = null; //clear socket upon close
        this.fire(ServerSearch.EVENT_WS_CLOSED);
      };

    } else if (this.socket.readyState !== WebSocket.OPEN) {
      //not yet open cache it
      this.initialMessages.push(asMessage(type, msg));
    } else {
      //send directly
      this.socket.send(asMessage(type, msg));
    }
  }


  loadQuery(query?: IQuery, k = 10, maxDepth = 10, justNetworkEdges: boolean = false, minLength = 0) {
    const msg = {
      k,
      maxDepth,
      query: query ? query.serialize() : null,
      just_network_edges: justNetworkEdges,
      minLength: minLength || 0
    };
    this.send(ServerSearch.SERVER_MSG_QUERY, msg);
  };

  /**
   * finds a set of nodes given a query
   * @param query
   * @param k
   */
  find(query?: IQuery, k = 10) {
    const msg = {
      k,
      query: query ? query.serialize() : null
    };
    this.send(ServerSearch.SERVER_MSG_FIND, msg);
  };

  /**
   *
   * @param nodeId
   * @param justNetworkEdges boolean whether just network edges should be considered
   * @param tag additional tag to transfer, identifying the query
   */
  loadNeighbors(nodeId, justNetworkEdges = false, tag?: any) {
    const msg = {
      node: nodeId,
      just_network_edges: justNetworkEdges,
      tag: undefined
    };
    if (tag) {
      msg.tag = tag;
    }
    this.send(ServerSearch.SERVER_MSG_NEIGBOR, msg);
  };

  clearSearchCache() {
    this.searchCache.clear();
  };

  /**
   * server search for auto completion
   * @param query the query to search
   * @param prop the property to look in
   * @param nodeType the node type to look in
   */
  async search(query: string, prop: string = 'name', nodeType: string = '_Network_Node'): Promise<Readonly<IServerSearchResult[]>> {
    const key = nodeType + '.' + prop;
    let cache: Map<string, any>;
    if (!this.searchCache.has(key)) {
      cache = this.searchCache[nodeType + '.' + prop] = new Map<string, any>();
    } else {
      cache = this.searchCache.get(key);
    }
    if (cache.has(query)) {
      return Promise.resolve(cache.get(query));
    }
    const data = await getAPIJSON('/pathway/search', {q: query, prop, label: nodeType, uc: uc()});
    cache.set(query, data.results);
    return data.results;
  };
}

const instance = new ServerSearch();

export const on = instance.on.bind(instance);
export const off = instance.off.bind(instance);
export const search = instance.search.bind(instance);
export const loadNeighbors = instance.loadNeighbors.bind(instance);
export const find = instance.find.bind(instance);
export const loadQuery = instance.loadQuery.bind(instance);
