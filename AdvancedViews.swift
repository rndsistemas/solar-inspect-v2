import SwiftUI

struct OperationsView:View {
    @EnvironmentObject var data:SolarData
    var body:some View {
        List {
            Section("Manutenção"){
                NavigationLink("Ordens de serviço",destination:WorkOrdersView())
                NavigationLink("Termografia",destination:FeatureView("Termografia","Importar imagens térmicas, classificar hotspots e vincular evidências aos módulos.","thermometer.sun.fill"))
                NavigationLink("Drone",destination:FeatureView("Drone","Importar missões, ortomosaicos e evidências aéreas georreferenciadas.","airplane"))
                NavigationLink("QR Code",destination:QRCodeView(code:"MOD-0001"))
            }
            Section("Equipe"){
                NavigationLink("Controle de equipes",destination:FeatureView("Equipes","Distribuição de serviços, responsáveis, prazos e produtividade.","person.3.fill"))
                NavigationLink("Assinatura digital",destination:SignatureView())
            }
        }.navigationTitle("Operação")
    }
}
struct WorkOrdersView:View {
    @EnvironmentObject var data:SolarData
    var body:some View {
        List(data.orders){o in VStack(alignment:.leading,spacing:5){
            HStack{Text(o.code).bold();Spacer();Text(o.state.rawValue).font(.caption)}
            Text(o.title);Text("\(o.module) • \(o.priority) • \(o.owner)").font(.caption).foregroundStyle(.secondary)
        }}.navigationTitle("Ordens de serviço")
    }
}
struct MoreView:View {
    var body:some View {
        List{
            NavigationLink("Parques / ativos",destination:AssetHierarchyView())
            NavigationLink("Importar KML / KMZ / GeoJSON / CSV",destination:ImportView())
            NavigationLink("Relatórios PDF / Excel",destination:ReportsView())
            NavigationLink("Notificações",destination:NotificationsView())
            NavigationLink("API / ERP / Nuvem",destination:SyncView())
            NavigationLink("Configurações",destination:FeatureView("Configurações","Usuários, perfis, permissões, tipos de defeito e parâmetros.","gearshape.fill"))
        }.navigationTitle("Mais")
    }
}
struct AssetHierarchyView:View {
    var body:some View { List{
        Label("Complexo Solar",systemImage:"sun.max.fill")
        Label("Blocos",systemImage:"square.grid.2x2")
        Label("Mesas / Trackers",systemImage:"rectangle.split.3x1")
        Label("Strings",systemImage:"link")
        Label("Módulos",systemImage:"square.grid.3x3")
    }.navigationTitle("Hierarquia de ativos") }
}
struct ImportView:View {
    @State private var format="KML"
    var body:some View { Form{
        Picker("Formato",selection:$format){ForEach(["KML","KMZ","GeoJSON","CSV","DWG/DXF convertido"],id:\.self){Text($0)}}
        Button("Selecionar arquivo"){ }
        Text("O importador de produção validará coordenadas, hierarquia e duplicidades antes da gravação no PostGIS.").font(.footnote).foregroundStyle(.secondary)
    }.navigationTitle("Importar planta") }
}
struct ReportsView:View {
    var body:some View { List{
        Label("Relatório geral do parque",systemImage:"doc.text")
        Label("Relatório fotográfico",systemImage:"photo.on.rectangle")
        Label("Módulos para substituição",systemImage:"exclamationmark.triangle")
        Label("Histórico de manutenção",systemImage:"clock.arrow.circlepath")
        Label("Exportar PDF / Excel",systemImage:"square.and.arrow.up")
    }.navigationTitle("Relatórios") }
}
struct SyncView:View {
    @State private var sync=false
    var body:some View { Form{
        Section("Arquitetura"){
            LabeledContent("Backend",value:"Supabase")
            LabeledContent("Banco",value:"PostgreSQL + PostGIS")
            LabeledContent("Fotos",value:"Object Storage")
            LabeledContent("Integrações",value:"REST API / ERP")
            LabeledContent("Modo campo",value:"Offline-first")
        }
        Button(sync ? "Sincronizado" : "Sincronizar agora"){sync=true}
    }.navigationTitle("Nuvem e API") }
}
struct NotificationsView:View {
    @State private var critical=true
    @State private var os=true
    @State private var due=true
    var body:some View { Form{
        Toggle("Falhas críticas",isOn:$critical);Toggle("Novas ordens de serviço",isOn:$os);Toggle("Prazos de manutenção",isOn:$due)
    }.navigationTitle("Notificações") }
}
struct SignatureView:View {
    @State private var signed=false
    var body:some View { VStack(spacing:22){
        Image(systemName:signed ? "checkmark.seal.fill":"signature").font(.system(size:70))
        Text(signed ? "Assinatura registrada":"Assinatura do responsável").font(.title2.bold())
        Button("Assinar"){signed=true}.buttonStyle(.borderedProminent).tint(.black)
    }.padding().navigationTitle("Assinatura digital") }
}
struct QRCodeView:View {
    let code:String
    var body:some View { VStack(spacing:20){
        Image(systemName:"qrcode").font(.system(size:160));Text(code).font(.title2.bold())
        Text("Na produção, a câmera identificará o QR e abrirá diretamente a ficha do módulo.").multilineTextAlignment(.center).foregroundStyle(.secondary)
    }.padding().navigationTitle("QR Code") }
}
struct FeatureView:View {
    let title:String,desc:String,icon:String
    init(_ t:String,_ d:String,_ i:String){title=t;desc=d;icon=i}
    var body:some View { VStack(spacing:18){Image(systemName:icon).font(.system(size:60));Text(title).font(.title.bold());Text(desc).multilineTextAlignment(.center).foregroundStyle(.secondary)}.padding().navigationTitle(title) }
}
