import SwiftUI
import MapKit

enum ModuleState: String, CaseIterable, Codable {
    case pending="Não inspecionado", normal="Normal", light="Leve", medium="Médio", critical="Crítico", done="Concluído"
    var color: Color {
        switch self {
        case .pending: return .gray
        case .normal: return .green
        case .light: return .yellow
        case .medium: return .orange
        case .critical: return .red
        case .done: return .blue
        }
    }
}
struct Inspection: Identifiable, Codable {
    var id=UUID(); var date=Date(); var type="Visual"; var defect="Sem defeito"
    var severity="Normal"; var inspector=""; var notes=""; var latitude:Double?; var longitude:Double?
}
struct PVModule: Identifiable, Codable {
    var id:String; var park:String; var block:String; var table:String; var string:String; var position:String
    var latitude:Double; var longitude:Double; var state:ModuleState = .pending
    var serial=""; var manufacturer=""; var inspections:[Inspection]=[]
}
enum WOState:String,CaseIterable,Codable { case open="Aberta", progress="Em execução", waiting="Aguardando", done="Concluída" }
struct WorkOrder:Identifiable,Codable {
    var id=UUID(); var code:String; var module:String; var title:String; var priority:String; var state:WOState; var owner:String; var created=Date()
}
final class SolarData:ObservableObject {
    @Published var modules:[PVModule]=[]
    @Published var orders:[WorkOrder]=[
        .init(code:"OS-0001",module:"MOD-0007",title:"Substituir módulo trincado",priority:"Alta",state:.open,owner:"Equipe O&M"),
        .init(code:"OS-0002",module:"MOD-0042",title:"Validar hotspot",priority:"Crítica",state:.progress,owner:"Termografia")
    ]
    init(){ modules=Self.demo() }
    static func demo()->[PVModule] {
        var a:[PVModule]=[]; var n=1
        for b in 1...3 { for t in 1...8 { for m in 1...12 {
            let lat = -8.0522 + Double(b)*0.00115 + Double((t-1)/4)*0.00034 + Double(m%2)*0.000045
            let lon = -34.9408 + Double((t-1)%4)*0.00052 + Double(m/2)*0.000055
            a.append(.init(id:String(format:"MOD-%04d",n),park:"Complexo Solar",block:String(format:"B%02d",b),
                table:String(format:"MESA-%03d",t),string:String(format:"STR-%02d",Int(ceil(Double(m)/4))),
                position:String(format:"M%02d",m),latitude:lat,longitude:lon))
            n += 1
        }}}
        return a
    }
}
