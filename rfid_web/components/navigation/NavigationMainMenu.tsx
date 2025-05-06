"use client";

import Link from "next/link";
import { Database, Printer, Tag } from "lucide-react";

import { buttonVariants } from "../ui/Button";
import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuList,
} from "../ui/NavigationMenu";

export const NavigationMainMenu = () => {
  return (
    <NavigationMenu className="hidden pl-4 md:pl-0 lg:block">
      <NavigationMenuList>
        <NavigationMenuItem asChild>
          <Link
            href="/inventory/masters"
            className={buttonVariants({
              variant: "ghost",
              size: "sm",
            })}
          >
            <Database className="mr-1" size={16} />
            在庫管理マスター
          </Link>
        </NavigationMenuItem>
        <NavigationMenuItem asChild>
          <Link
            href="/inventory/items"
            className={buttonVariants({
              variant: "ghost",
              size: "sm",
            })}
          >
            <Tag className="mr-1" size={16} />
            RFIDアイテム
          </Link>
        </NavigationMenuItem>
        <NavigationMenuItem asChild>
          <Link
            href="/inventory/print"
            className={buttonVariants({
              variant: "ghost",
              size: "sm",
            })}
          >
            <Printer className="mr-1" size={16} />
            プリンター
          </Link>
        </NavigationMenuItem>
      </NavigationMenuList>
    </NavigationMenu>
  );
};
