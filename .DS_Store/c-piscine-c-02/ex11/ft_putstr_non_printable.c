/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_putstr_non_printable.c                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: xcarroll <xcarroll@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/21 19:37:15 by xcarroll          #+#    #+#             */
/*   Updated: 2022/02/24 00:15:19 by xcarroll         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <unistd.h>
#include <stdio.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	print_hex(int c)
{
	char	*hex;

	hex = "0123456789abcdef";
	if (c < 16)
	{
		ft_putchar('0');
		ft_putchar(hex[c]);
	}
	else
	{
		print_hex(c / 16);
		print_hex(c % 16);
	}
}

void	ft_putstr_non_printable(char *str)
{
	int	i;

	i = 0;
	while (str[i] != '\0')
	{
		if (str[i] >= 32 && str[i] <= '~')
			ft_putchar(str[i]);
		else
		{
			ft_putchar(92);
			print_hex(str[i]);
		}
		i++;
	}
}
