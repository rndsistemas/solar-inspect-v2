import SwiftUI
import MapKit

struct RootView:View {
    @EnvironmentObject var data:SolarData
    @State private var logged=false
    var body:some View {
        if logged { MainTabs() } else { LoginView(logged:$logged) }
    }
}
struct LoginView:View {
    @Binding var logged:Bool
    @State private var email="inspetor@solarinspect.com"
    @State private var password=""
    var body:some View {
        VStack(spacing:22){
            Spacer()
            Image(systemName:"sun.max.fill").font(.system(size:64)).foregroundStyle(.yellow)
            Text("SOLAR INSPECT").font(.largeTitle.bold())
            Text("Inspeção • Manutenção • Georreferenciamento").foregroundStyle(.secondary)
            TextField("E-mail",text:$email).textFieldStyle(.roundedBorder).textInputAutocapitalization(.never)
            SecureField("Senha",text:$password).textFieldStyle(.roundedBorder)
            Button("Entrar"){logged=true}.buttonStyle(.borderedProminent).tint(.black).frame(maxWidth:.infinity)
            Spacer()
        }.padding(28)
    }
}
struct MainTabs:View {
    var body:some View {
        TabView {
            NavigationStack { DashboardView() }.tabItem{Label("Início",systemImage:"chart.bar.fill")}
            NavigationStack { SolarMapView() }.tabItem{Label("Mapa",systemImage:"map.fill")}
            NavigationStack { OperationsView() }.tabItem{Label("Operação",systemImage:"wrench.and.screwdriver.fill")}
            NavigationStack { MoreView() }.tabItem{Label("Mais",systemImage:"square.grid.2x2.fill")}
        }.tint(.black)
    }
}
struct DashboardView:View {
    @EnvironmentObject var data:SolarData
    var defects:Int { data.modules.filter{[.light,.medium,.critical].contains($0.state)}.count }
    var body:some View {
        List {
            Section("Complexo solar") {
                Metric("Módulos", "\(data.modules.count)", "square.grid.3x3.fill")
                Metric("Defeitos", "\(defects)", "exclamationmark.triangle.fill")
                Metric("OS abertas", "\(data.orders.filter{$0.state != .done}.count)", "wrench.fill")
            }
            Section("Atalhos") {
                NavigationLink("Inspeções críticas",destination:Text("Filtro de ocorrências críticas"))
                NavigationLink("Relatórios",destination:ReportsView())
                NavigationLink("Sincronização",destination:SyncView())
            }
        }.navigationTitle("SOLAR INSPECT")
    }
}
struct Metric:View {
    let title:String,value:String,icon:String
    init(_ t:String,_ v:String,_ i:String){title=t;value=v;icon=i}
    var body:some View { HStack{Image(systemName:icon).frame(width:28);Text(title);Spacer();Text(value).font(.title3.bold())} }
}
struct SolarMapView:View {
    @EnvironmentObject var data:SolarData
    @State private var selected:PVModule?
    @State private var search=""
    @State private var state:ModuleState?
    @State private var camera:MapCameraPosition = .region(.init(center:.init(latitude:-8.0505,longitude:-34.9380),span:.init(latitudeDelta:0.008,longitudeDelta:0.009)))
    var visible:[PVModule] { data.modules.filter{ m in
        (state == nil || m.state == state) && (search.isEmpty || "\(m.id) \(m.block) \(m.table) \(m.string)".localizedCaseInsensitiveContains(search))
    }}
    var body:some View {
        ZStack(alignment:.top){
            Map(position:$camera){
                ForEach(visible){m in Annotation(m.id,coordinate:.init(latitude:m.latitude,longitude:m.longitude)){
                    Button{selected=m}{RoundedRectangle(cornerRadius:2).fill(m.state.color).frame(width:8,height:18).overlay(RoundedRectangle(cornerRadius:2).stroke(.black.opacity(0.4)))}
                }}
            }
            VStack{
                TextField("Buscar módulo, mesa, string...",text:$search).textFieldStyle(.roundedBorder).padding(.horizontal)
                ScrollView(.horizontal,showsIndicators:false){HStack{
                    Button("Todos"){state=nil}
                    ForEach(ModuleState.allCases,id:\.self){s in Button(s.rawValue){state=s}}
                }.buttonStyle(.bordered).padding(.horizontal)}
            }.padding(.top,8)
        }.navigationTitle("Mapa do complexo")
        .sheet(item:$selected){m in NavigationStack{ModuleView(module:m)}.presentationDetents([.medium,.large])}
    }
}
