import { MainLayout } from "@/components/ui/common/MainLayout";
import { ECNavigation } from "@/components/modules/ec/ECNavigation";

interface ECLayoutProps {
  children: React.ReactNode;
}

export default function ECLayout({ children }: ECLayoutProps) {
  return (
    <MainLayout>
      <div className="flex flex-1 flex-col">
        <ECNavigation />
        <div className="px-10">{children}</div>
      </div>
    </MainLayout>
  );
}
